Class SQLProvider : ProviderBase {
    
    SQLProvider([string]$ConnectionName
                , [int]$CommandTimeout
                , [System.Data.SqlClient.SqlConnection]$Connection) {

        $this.ConnectionName = $ConnectionName
        $this.CommandTimeout = $CommandTimeout
        $this.Connection = $Connection
        
        $messages = $this.Messages
        $handler = {Param($sender, [System.Data.SqlClient.SqlInfoMessageEventArgs]$e)
            $Messages.Enqueue(([SqlMessage]@{Generated=(Get-Date); Message=$e.Message}))
        }.GetNewClosure()

        $this.Connection.add_InfoMessage([System.Data.SqlClient.SqlInfoMessageEventHandler]$handler)
    }

    [string] ProviderType() { return "SQL" }

    [PSCustomObject] ConnectionInfo() {
        return [PSCustomObject]@{
            ConnectionName = $this.ConnectionName
            ProviderType = $this.ProviderType()
            ConnectionState = $this.Connection.State
            ConnectionString = $this.Connection.ConnectionString
            ServerVersion = $this.Connection.ServerVersion
            DataSource = $this.Connection.DataSource
            Database = $this.Connection.Database
            CommandTimeout = $this.CommandTimeout
            HasTransaction = $this.HasTransaction()
        }
    }

    [void] ChangeDatabase([string]$DatabaseName) { 

    }

    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd) {
        $ds = [System.Data.DataSet]::new()
        $da = [System.Data.SqlClient.SqlDataAdapter]::new($cmd)
        Try {
            $da.Fill($ds)
            return $ds 
        }
        Finally { $da.dispose() }
    }

    [long] BulkLoad([System.Data.IDataReader]$DataReader
                    , [string]$DestinationTable
                    , [hashtable]$ColumnMap
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
            
            If ($Notify) {
                $bcp.NotifyAfter = $BatchSize
                $bcp.add_SqlRowsCopied({
                    Param($sender, [System.Data.SqlClient.SqlRowsCopiedEventArgs]$e)
                    $RowCount = $e.RowsCopied
                    $Notify.Invoke($e.RowsCopied)
                })
            }
            Else {
                $bcp.NotifyAfter = $BatchSize
                $bcp.add_SqlRowsCopied({
                    Param($sender, [System.Data.SqlClient.SqlRowsCopiedEventArgs]$e)
                    $RowCount = $e.RowsCopied
                })
            }

            $bcp.WriteToServer($DataReader)
        }
        Finally {
            $bcp.Dispose()            
            $DataReader.Dispose()
        }
        
        return $RowCount
    }

    static [System.Data.IDbConnection] CreateConnection([hashtable]$ht) {
        If($ht.ParameterSetName -notin @("Default", "Conn", "user", "cred")) {
            Throw [System.InvalidOperationException]::new("Invalid ParameterSet passed to CreateConnection")
        }
        
        $sb = [System.Data.SqlClient.SqlConnectionStringBuilder]::new()

        If($ht.ContainsKey("ConnectionString")) { $sb["Connection String"] = $ht.ConnectionString }
        Else {
            If($ht.ContainsKey("DataSource")) { $sb.Server = $ht.DataSource }
            If($ht.ContainsKey("InitialCatalog")) { $sb.Database = $ht.InitialCatalog }
            If($ht.ContainsKey("User")) { $sb["User Id"] = $ht.User }
            Else { $sb["Integrated Security"] = $true }
            If($ht.ContainsKey("Password")) { $sb.Password = $ht.Password }
        }        
        
        $sb["Application Name"] = "PowerShell"
        
        If($ht.ContainsKey("Credential")) {
            [securestring]$sqlCred = $ht.Credential.Password.Copy()
            $sqlCred.MakeReadOnly()

            $conn =  [System.Data.SqlClient.SqlConnection]::new($sb.ConnectionString, [System.Data.SqlClient.SqlCredential]::new($ht.Credential.UserName, $sqlCred))
        }
        Else { $conn = [System.Data.SqlClient.SqlConnection]::new($sb.ConnectionString) }

        $conn.Open()
        return $conn
    }    
}