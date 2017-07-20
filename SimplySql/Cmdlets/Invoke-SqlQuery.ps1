<#
.Synopsis
    Executes a query and returns data.

.Description
    Executes a query against the targeted connection and returns the data.
    This can handle multiple result sets (if underlying provider supports it).
    If there are multiple result sets, the output is datatables, otherwise
    datarows.

    If the <Stream> switch is used, only the first result set is returned and
    the output is a PSObject for each row in the result set.

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

.Parameter Stream
    Uses a datareader to stream PSObject representing the results of the query
    to the pipeline, results will appear as soon as the connection begins
    returning data.  Only returns the first resultset if there are multiples.

.Example
    Run a simple query and return the output
    
    Invoke-SqlQuery -Query "SELECT * FROM TABLE"

#>
Function Invoke-SqlQuery {
    [CmdletBinding()]
    Param([Parameter(Mandatory, Position=0)][AllowEmptyString()][string[]]$Query
        , [Parameter(Position=1)][hashtable]$Parameters = @{}
        , [int]$CommandTimeout = -1
        , [Alias("cn")][string]$ConnectionName = "default"
        , [switch]$Stream)
    
    If(TestConnectionName -ConnectionName $ConnectionName) {
        [string]$Query = $Query -join [System.Environment]::NewLine
        If(-not $Parameters) { $Parameters = @{} }
        
        $cmd = $Script:Connections.$ConnectionName.GetCommand($Query, $CommandTimeout, $Parameters)
        Try {
            If($stream.IsPresent) {
                $dr = $cmd.ExecuteReader()
                Try { [DataReaderToPSObject]::Translate($dr) }
                Finally { $dr.Dispose() }
            }
            Else {
                Try {
                    $ds = $Script:Connections.$ConnectionName.GetDataSet($cmd)
                    If($ds.Tables.Count -gt 1) { Write-Output $ds.Tables }
                    Else { Write-Output $ds.Tables[0].Rows }
                }
                Finally { If(Test-Path variable:ds) { $ds.Dispose() } }
            }
        }
        Finally { $cmd.Dispose() }
    }
}

Set-Alias -Name isq -Value Invoke-SqlQuery
Export-ModuleMember -Function Invoke-SqlQuery -Alias isq