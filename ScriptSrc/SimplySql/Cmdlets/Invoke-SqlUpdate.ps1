<#
.Synopsis
    Executes a query and returns number of record affected.

.Description
    Executes a query against the targeted connection and returns the the
    number of records affected.

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
    Invoke-SqlUpdate -Query "TRUNCATE TABLE employees"

.Example
    Invoke-SqlUpdate -Query "UPDATE employees SET salary = @val WHERE manager = @managerId" -Parameters @{val = 999999; managerId = 549}

#>
Function Invoke-SqlUpdate {
    [CmdletBinding(DefaultParameterSetName="default")]
    Param([Parameter(Mandatory, ParameterSetName="default", Position=0)][AllowEmptyString()][string[]]$Query
        , [Parameter(ParameterSetName="default",Position=1)][hashtable]$Parameters = @{}
        , [Parameter(ParameterSetName="default")][int]$CommandTimeout = -1
        , [Parameter(Mandatory,ParameterSetName="cmd")][System.Data.IDbCommand]$Command
        , [ValidateNotNullOrEmpty()][Alias("cn")][string]$ConnectionName = "default")
    
    If(TestConnectionName -ConnectionName $ConnectionName) {
        If($PSCmdlet.ParameterSetName -eq "default") {
            [string]$Query = $Query -join [System.Environment]::NewLine
            If(-not $Parameters) { $Parameters = @{} }
            
            $cmd = $Script:Connections.$ConnectionName.GetCommand($Query, $CommandTimeout, $Parameters)
            Try { Write-Output $cmd.ExecuteNonQuery() }
            Finally { $cmd.Dispose() }
        }
        Else {
            $Script:Connections.$ConnectionName.AttachTransaction($Command)
            Write-Output $Command.ExecuteNonQuery()
        }
    }
}

Set-Alias -Name isu -Value Invoke-SqlUpdate
Export-ModuleMember -Function Invoke-SqlUpdate -Alias isu