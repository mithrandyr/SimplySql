<#
.Synopsis
    Executes a Scalar query.

.Description
    Executes a Scalar query against the targeted connection.
    If the sql statement generates multiple rows and/or columns,
    only the first column of the first row is returned.

.Parameter Query
    SQL statement to run.

.Parameter Parameters
    Parameters required by the query. Key matches the parameter name,
    Value is the value of the parameter.

.Parameter CommandTimeout
    The timeout, in seconds, for this SQL statement, defaults to the command
    timeout for the SqlConnection.

.Parameter ConnectionName
    User defined name for connection.
#>
Function Invoke-SqlScalar {
    [CmdletBinding()]
    Param([Parameter(Mandatory)][string[]]$Query
        , [hashtable]$Parameters = @{}
        , [int]$CommandTimeout = -1
        , [string]$ConnectionName = "default")
    
    If(TestConnectionName -ConnectionName $ConnectionName) {
        [string]$Query = $Query -join [System.Environment]::NewLine
        Write-Output $Script:Connections.$ConnectionName.GetScalar($Query, $CommandTimeout, $Parameters)
    }
}

Set-Alias -Name iss -Value Invoke-SqlScalar
Export-ModuleMember -Function Invoke-SqlScalar -Alias iss