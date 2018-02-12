#Load Up SQLite libraries
Add-Type -Path "$PSScriptRoot\System.Data.SQLite.dll"

#Provider Class
. "$PSScriptRoot\provider.ps1"

#Open Cmdlet
Function Open-SQLiteConnection {
    <#
    .Synopsis
        Open a connection to a SQLite database file.

    .Description
        Open a connection to a SQLite database file.
        SQLite (System.Data.SQLite)
        SQLite Development Team @ https://sqlite.org/
        .NET Provider @ http://system.data.sqlite.org/ 

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

    .Parameter Password
        Password for the database file.

    #>
    [CmdletBinding(DefaultParameterSetName="default")]
    Param([Parameter(ValueFromPipelineByPropertyName)][Alias("cn")][string]$ConnectionName = "default"
        , [Parameter(ValueFromPipelineByPropertyName)][int]$CommandTimeout = 30
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=0)][Alias("FilePath")][string]$DataSource = ":memory:"
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=1)][string]$Password
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="Conn")][string]$ConnectionString)
    
    If($Script:Connections.ContainsKey($ConnectionName)) { Close-SqlConnection $ConnectionName }

    $sb = [System.Data.SQLite.SQLiteConnectionStringBuilder]::new()

    If($PSCmdlet.ParameterSetName -eq "Conn") { $sb["ConnectionString"] = $ConnectionString }
    Else {
        If($DataSource -ne ":memory:") {
            $parent = Split-Path -Path $DataSource -Parent
            If(-not $parent) { $parent = $pwd.Path}
            Else {
                If(-not (Test-Path $parent)) {
                    New-Item -Path $parent -ItemType Directory | Out-Null
                }
            }

            $parent = $parent | Resolve-Path | ForEach-Object ProviderPath

            $DataSource = Join-Path $parent -ChildPath (Split-Path $DataSource -Leaf)
        }
        $sb["Data Source"] = $DataSource
        If($Password) { $sb.Password = $Password }
    }
    
    $conn = [System.Data.SQLite.SQLiteConnection]::new($sb.ConnectionString)

    Try { $conn.Open() }
    Catch {
        $conn.Dispose()
        Throw $_
    }
    $Script:Connections.$ConnectionName = [SQLiteProvider]::new($ConnectionName, $CommandTimeout, $conn)
}

Export-ModuleMember -Function Open-SQLiteConnection