<#
.Synopsis
    Tests to see if there is a connection.

.Description
    Tests to see if there is a connection, use the -All switch to determine
    if there are any connections.

.Parameter ConnectionName
    User defined name for the connection to test for.

.Parameter All
    Returns true if there are any connections, otherwise false.

#>
Function Test-SqlConnection {
    [cmdletBinding(DefaultParameterSetName="single")]
    Param([Parameter(ParameterSetName="single",Position=0)][ValidateNotNullOrEmpty()][Alias("cn")][string]$ConnectionName = "default"
        , [Parameter(Mandatory, ParameterSetName="all")][switch]$All)

    If($all.IsPresent -and $Script:Connections.Count -gt 0) { return $true }
    ElseIf($Script:Connections.ContainsKey($ConnectionName)) { return $true }
    Else { return $false }
}

Set-Alias -Name tsc -Value Test-SqlConnection
Export-ModuleMember -Function Test-SqlConnection -Alias tsc