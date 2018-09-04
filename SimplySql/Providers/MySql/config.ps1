#Load Up My Sql libraries
Add-Type -Path "$PSScriptRoot\MySql.Data.dll"

#Provider Class
. "$PSScriptRoot\provider.ps1"

#Open Cmdlet
Function Open-MySqlConnection {
    <#
    .Synopsis
        Open a connection to a MySql Database.

    .Description
        Open a connection to a MySql Database.
        
        MySql (MySql.Data)
        MySql Managed Data Access @ https://dev.mysql.com/downloads/
        .NET Provider @ https://www.nuget.org/packages/mysql.Data/6.9.9

    .Parameter ConnectionName
        The name to associate with the newly created connection.
        This connection will be used with other cmdlets when specifying
        -ConnectionName <name>.  If you don't specify one, it will be
        set to the default.

    .Parameter ConnectionString
        Specifies a provider specific connectionstring to be used.

    .Parameter CommandTimeout
        The default command timeout to be used for all commands executed against this connection.

    .Parameter Server
        The Server for the connection.

    .Parameter Database
        Database name.

    .Parameter Port
        Port to connect on, if different from default (3306).

    .Parameter UserName
        User to authenticate as. (deprecated, use -Credential)

    .Parameter Password
        Password for the user. (deprecated, use -Credential)
    
    .Parameter SSLMode
        None: Do not use SSL.
        Required: Always use SSL. Deny connection if server does not support SSL. Do not perform server certificate validation.
        VerifyCA: Always use SSL. Validate server SSL certificate, but different host name mismatch.
        VerifyFull: Always use SSL and perform full certificate validation.

    #>
    [CmdletBinding(DefaultParameterSetName="default")]
    Param([Parameter(ValueFromPipelineByPropertyName)][Alias("cn")][string]$ConnectionName = "default"
        , [Parameter(ValueFromPipelineByPropertyName)][int]$CommandTimeout = 30
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=0)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass", Position=0)][string]$Server = "localhost"
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=1)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass", Position=1)][string]$Database = "mysql"
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default")]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass")][int]$Port = 3306
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="default")][pscredential]$Credential
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="userpass")][string]$UserName
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="userpass")][string]$Password
        , [Parameter(ValueFromPipeline, ParameterSetName="default")]
            [Parameter(ValueFromPipeline, ParameterSetName="userpass")]
            [ValidateSet("None","Required","VerifyCA","VerifyFull")][string]$SSLMode = "None"
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="Conn")][string]$ConnectionString)
    
    If($Script:Connections.ContainsKey($ConnectionName)) { Close-SqlConnection $ConnectionName }

    $sb = [MySql.Data.MySqlClient.MySqlConnectionStringBuilder]::new()

    If($PSCmdlet.ParameterSetName -eq "Conn") { $conn = [MySql.Data.MySqlClient.MySqlConnection]::new($ConnectionString) }
    Else {
        $sb.Server = $Server
        $sb.Database = $Database
        If($Port) { $sb.Port = $Port }
        If($Credential) {
            $sb.UserID = $Credential.UserName
            $sb.Password = $Credential.GetNetworkCredential().Password
        }
        Else {
            Write-Warning "You are using -UserName and -Password, these options are deprecated and will be removed in the future.  Please consider using -Credential."
            $sb.UserId = $UserName
            $sb.Password = $Password
        }

        $sb.UseAffectedRows = $true
        $sb.AllowUserVariables = $true
        $sb.SslMode = $SSLMode

        $conn = [MySql.Data.MySqlClient.MySqlConnection]::new($sb.ConnectionString)    
        $sb.Clear()
        $sb = $null
        Remove-Variable sb    
    }
    
    Try { $conn.Open() }
    Catch {
        $conn.Dispose()
        Throw $_
    }
    $Script:Connections.$ConnectionName = [MySqlProvider]::new($ConnectionName, $CommandTimeout, $conn)
}

Export-ModuleMember -Function Open-MySqlConnection