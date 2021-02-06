<#
.Synopsis
    Set options on the SqlConnection.

.Description
    Set Database and/or Command Timeout for the SqlConnection.  Changing the
    database may not be valid for all providers.

.Parameter ConnectionName
    User defined name for connection.

.Parameter Database
    Name of the database to connect to.

.Parameter CommandTimeout
    Command timeout in seconds, only changed if greater than 0.

#>
Function Set-SqlConnection {
    [cmdletBinding()]
    Param([Parameter(Position=0)][string]$Database
        , [int]$CommandTimeout = -1
        , [ValidateNotNullOrEmpty()][Alias("cn")][string]$ConnectionName = "default")

    If(TestConnectionName -ConnectionName $ConnectionName) {
        If($CommandTimeout -ge 0) {
            $Script:Connections.$ConnectionName.CommandTimeout = $CommandTimeout
        }        
        If($Database) {
            Try { $Script:Connections.$ConnectionName.ChangeDatabase($Database) }
            Catch [System.NotImplementedException], [System.NotSupportedException] {
                Write-Warning ("Changing the databse is not available for this provider: {0}" -f $Script:Connections[$ConnectionName].ProviderType())
            }
        }
    }
}

Export-ModuleMember -Function Set-SqlConnection