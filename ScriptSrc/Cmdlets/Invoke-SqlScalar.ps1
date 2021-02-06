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

    .Example
    Invoke-SqlScalar -Query "SELECT Count(1) FROM TABLE"

.Example
    Invoke-SqlQuery -Query "SELECT Count(1) FROM TABLE WHERE colb > @someDate" -Parameters @{someDate = (Get-Date)}

#>
Function Invoke-SqlScalar {
    [CmdletBinding()]
    Param([Parameter(Mandatory, Position=0)][AllowEmptyString()][string[]]$Query
        , [Parameter(Position=1)][hashtable]$Parameters = @{}
        , [int]$CommandTimeout = -1
        , [ValidateNotNullOrEmpty()][Alias("cn")][string]$ConnectionName = "default")
    
    If(TestConnectionName -ConnectionName $ConnectionName) {
        [string]$Query = $Query -join [System.Environment]::NewLine
        If(-not $Parameters) { $Parameters = @{} }
        Write-Output $Script:Connections.$ConnectionName.GetScalar($Query, $CommandTimeout, $Parameters)
    }
}

Set-Alias -Name iss -Value Invoke-SqlScalar
Export-ModuleMember -Function Invoke-SqlScalar -Alias iss