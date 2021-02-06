#Provider Class
Class SQLProvider : ProviderBase {
    
    SQLProvider([string]$ConnectionName
                , [int]$CommandTimeout
                , [System.Data.SqlClient.SqlConnection]$Connection) {

        $this.ConnectionName = $ConnectionName
        $this.CommandTimeout = $CommandTimeout
        $this.Connection = $Connection
        
        $messages = $this.Messages
        $handler = {Param($sender, [System.Data.SqlClient.SqlInfoMessageEventArgs]$e)
            $messages.Enqueue(([SqlMessage]@{Received=(Get-Date); Message=$e.Message}))
        }.GetNewClosure()

        $this.Connection.add_InfoMessage([System.Data.SqlClient.SqlInfoMessageEventHandler]$handler)
    }

    [string] ProviderType() { return "MSSQL" }

    [PSCustomObject] ConnectionInfo() {
        return [PSCustomObject]@{
            ConnectionName = $this.ConnectionName
            ProviderType = $this.ProviderType()
            ConnectionState = $this.Connection.State
            ConnectionString = $this.Connection.ConnectionString
            ServerVersion = $this.Connection.ServerVersion
            Server = $this.Connection.DataSource
            Database = $this.Connection.Database
            CommandTimeout = $this.CommandTimeout
            HasTransaction = $this.HasTransaction()
        }
    }

    [void] ChangeDatabase([string]$DatabaseName) { $this.Connection.ChangeDatabase($DatabaseName) }

    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd, [Boolean]$ProviderTypes) {
        $ds = [System.Data.DataSet]::new()
        $da = [System.Data.SqlClient.SqlDataAdapter]::new($cmd)
        if ($ProviderTypes) {
            $da.ReturnProviderSpecificTypes = $true
        }
        Try {
            $da.Fill($ds)
            return $ds 
        }
        Catch { Throw $_ }
        Finally { $da.dispose() }
    }

    [long] BulkLoad([System.Data.IDataReader]$DataReader
                    , [string]$DestinationTable
                    , [hashtable]$ColumnMap = @{}
                    , [int]$BatchSize
                    , [int]$BatchTimeout
                    , [ScriptBlock]$Notify) {
        
        [long]$RowCount = 0
        $bcp = [System.Data.SqlClient.SqlBulkCopy]::new($this.Connection, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity, $null)
        Try {
            $bcp.DestinationTableName = $DestinationTable
            $bcp.BatchSize = $BatchSize
            $bcp.BulkCopyTimeout = $BatchTimeout
            $bcp.EnableStreaming = $true

            If($ColumnMap -and $ColumnMap.Count -gt 0) {
                ForEach ($de in $ColumnMap.GetEnumerator()) {
                    $bcp.ColumnMappings.Add($de.Key, $de.Value)
                }
            }
            
            If($Notify) {
                $bcp.NotifyAfter = $BatchSize
                $bcp.add_SqlRowsCopied({
                    Param($sender, [System.Data.SqlClient.SqlRowsCopiedEventArgs]$e)
                    $Notify.Invoke($e.RowsCopied)
                })
            }
            
            $RowCount -= $this.GetScalar("SELECT COUNT(1) FROM $DestinationTable", 30, @{})
            $bcp.WriteToServer($DataReader)
            $RowCount += $this.GetScalar("SELECT COUNT(1) FROM $DestinationTable", 30, @{})
        }
        Finally {
            $bcp.Close()
            $bcp.Dispose()
            $DataReader.Close()
            $DataReader.Dispose()
            $this.Update("IF EXISTS(SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('$DestinationTable') AND is_identity = 1) SET IDENTITY_INSERT $DestinationTable OFF", 30, @{}) | Out-Null #make sure Identity Insert is off...
        }
        
        return $RowCount
    }
}

#Open Cmdlet
Function Open-SqlConnection {
    <#
    .Synopsis
        Open a connection to a SQL Server.

    .Description
        Open a connection to a SQL Server.  Default authentication is Integrated Windows Authetication.
        
        System.Data.SqlClient.

    .Parameter ConnectionName
        The name to associate with the newly created connection.
        This connection will be used with other cmdlets when specifying
        -ConnectionName <name>.  If you don't specify one, it will be
        set to the default.

    .Parameter ConnectionString
        Specifies a provider specific connectionstring to be used.

    .Parameter CommandTimeout
        The default command timeout to be used for all commands executed against this connection.

    .Parameter DataSource
        The datasource for the connection.

    .Parameter InitialCatalog
        Database catalog connecting to.

    .Parameter UserName
        Username to connect as.

    .Parameter Password
        Password for the connecting user.

    .Parameter AzureAD
        Use this when connecting to an Azure SQL Database and you are using Azure AD credentials.
        You can specify the credentials either by using the UserName/Password parameters or by
        passing in a credential object to the Credential parameter.
    
    .Parameter AzureToken
        Pass in Azure Token (make sure you use the proper resource). If your token begins with "bearer "
        that will be stripped off first.

    .Parameter Credential
        Credential object containing the SQL user/pass.

    #>
    [CmdletBinding(DefaultParameterSetName="default")]
    Param([Parameter(ValueFromPipelineByPropertyName)][Alias("cn")][string]$ConnectionName = "default"
        , [Parameter(ValueFromPipelineByPropertyName)][int]$CommandTimeout = 30
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=0)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="user", Position=0)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="cred", Position=0)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="token", Position=0)]
                [Alias("SqlInstance","SqlServer","DataSource")][string]$Server = "localhost"
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=1)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="user", Position=1)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="cred", Position=1)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="token", Position=1)]
                [Alias("SqlDatabase","InitialCatalog")][string]$Database = "master"
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="user")]
            [string]$UserName
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="user")]
            [string]$Password
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="cred")]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="conn")]
                [pscredential]$Credential
        , [Parameter(ParameterSetName="user")]
            [Parameter(ParameterSetName="cred")][Switch]$AzureAD
        , [Parameter(Mandatory, ParameterSetName="token")][string]$AzureToken
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="Conn")]
            [Parameter(ParameterSetName="token")][string]$ConnectionString)

    If($Script:Connections.ContainsKey($ConnectionName)) { Close-SqlConnection $ConnectionName }

    If($ConnectionString) { $sb = [System.Data.SqlClient.SqlConnectionStringBuilder]::new($ConnectionString) }
    Else {
        $sb = [System.Data.SqlClient.SqlConnectionStringBuilder]::new()

        If($Server) { $sb.Server = $Server }
        If($Database) { $sb.Database = $Database }
        If($UserName) { 
            Write-Warning "You are using -UserName and -Password, these options are deprecated and will be removed in the future.  Please consider using -Credential."
            $sb["User Id"] = $UserName
            $sb.Password = $Password
        }
        If($AzureAD) {
            $sb.Encrypt = $true
            $sb.Authentication = "Active Directory Password"
        }
        If(-not $UserName -and -not $Credential -and -not $AzureToken) { $sb["Integrated Security"] = $true }
    }
    $sb["Application Name"] = "PowerShell ({0})" -f $ConnectionName

    If($Credential) {
        [securestring]$sqlCred = $Credential.Password.Copy()
        $sqlCred.MakeReadOnly()
        $conn =  [System.Data.SqlClient.SqlConnection]::new($sb.ConnectionString, [System.Data.SqlClient.SqlCredential]::new($Credential.UserName, $sqlCred))
    }
    Else {
        $conn = [System.Data.SqlClient.SqlConnection]::new($sb.ConnectionString)
        if($AzureToken) { 
            if($AzureToken.Substring(0,7) -eq "bearer ") { $AzureToken = $AzureToken.Substring(7) }
            $conn.AccessToken = $AzureToken
        }
    }
    
    Try { $conn.Open() }
    Catch {
        $conn.Dispose()
        Throw $_
    }
    $Script:Connections.$ConnectionName = [SQLProvider]::new($ConnectionName, $CommandTimeout, $conn)
}

Export-ModuleMember -Function Open-SqlConnection