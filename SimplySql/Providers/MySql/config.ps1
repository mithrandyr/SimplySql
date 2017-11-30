#Load Up My Sql libraries
Add-Type -Path "$PSScriptRoot\MySql.Data.dll"

#Provider Class
. "$PSScriptRoot\provider.ps1"

#Open Cmdlet
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
    User to authenticate as.

.Parameter Password
    Password for the user.

#>
Function Open-MySqlConnection {
    [CmdletBinding(DefaultParameterSetName="default")]
    Param([Parameter(ValueFromPipelineByPropertyName)][Alias("cn")][string]$ConnectionName = "default"
        , [Parameter(ValueFromPipelineByPropertyName)][int]$CommandTimeout = 30
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=0)][string]$Server = "localhost"
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=1)][string]$Database = "mysql"
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default")][int]$Port = 3306
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="default")][string]$UserName
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="default")][string]$Password
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="Conn")][string]$ConnectionString)
    
    If($Script:Connections.ContainsKey($ConnectionName)) { Close-SqlConnection $ConnectionName }

    $sb = [MySql.Data.MySqlClient.MySqlConnectionStringBuilder]::new()

    If($PSCmdlet.ParameterSetName -eq "Conn") { $sb["ConnectionString"] = $ConnectionString }
    Else {
        $sb.Server = $Server
        $sb.Database = $Database
        If($Port) { $sb.Port = $Port }
        $sb.UserId = $UserName
        $sb.Password = $Password

        $sb.UseAffectedRows = $true
        $sb.AllowUserVariables = $true    
    }
    
    $conn = [MySql.Data.MySqlClient.MySqlConnection]::new($sb.ConnectionString)

    Try { $conn.Open() }
    Catch {
        $conn.Dispose()
        Throw $_
    }
    $Script:Connections.$ConnectionName = [MySqlProvider]::new($ConnectionName, $CommandTimeout, $conn)
}

Export-ModuleMember -Function Open-MySqlConnection