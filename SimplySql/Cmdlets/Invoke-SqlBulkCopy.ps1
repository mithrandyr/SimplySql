<#
.Synopsis
    Executes a bulk copy between two connections.

.Description
    Executes a bulk copy operation between two connections.  This is highly
    optimized if the destination has a managed bulkcopy implemenation, otherwise
    it is only generally optimized.  For example, SQL Server has a bulk copy
    class (SqlBulkCopy) that is easily implemented and provides an efficient
    means of inserting data into SQL Server.

    The default implemenation, if the provider does not provider a managed 
    bulk copy mechanism is to prepare the sql insert, and wrap multiple inserts
    into a single transaction (batching).  This provides a significant
    performance improvement over looping with Invoke-SqlUpdate.

    CONSIDERATIONS
    * You must specify either a SourceConnectionName or DestinationConnectionName,
        whichever one is not specified will use 'default', not specifying either
        will cause an error.     
    * If you don’t specify DestinationTable, it will use SourceTable; however
        DestinationTable is required if you use SourceQuery.
    * If you specify ColumnMap and Source Table, then the select against the
        SourceConnection will be limited to the columns you specified in ColumnMap.

    Returns number of rows copied.

.Parameter SourceConnectionName
    User defined name for connection where data will be queried from.

.Parameter DestinationConnectionName 
    User defined name for connection where data will be inserted to.

.Parameter SourceTable 
    The name of the table in the source connection.

.Parameter DestinationTable 
    The name of the table to write to in the destination connection.
    If not specified, will be taken from SourceTable parameter.

.Parameter ColumnMap
    Key is the column name in the source connection.
    Value is the column name in the destination connection.

.Parameter BatchSize
    How many inserts are batched together at one time.

.Parameter BatchTimeout
    How long, in seconds, that each batch can take.
    Defaults to the command timeout for the source connection.

.Parameter Notify
    If present, as each batch completes a progress notification will be
    generated with the total number of rows inserted so far.

.Parameter NotifyAction
    If specified, then on the completion of each batch, this action will be invoked.
    The first argument will have the rows completed so far, either use $args[0]
    or specify a param block.    

.Parameter SourceQuery
    The query to determine the source data, instead of specifying a table.

.Parameter SourceParameters
    Parameters needed for the source query.

#>
Function Invoke-SqlBulkCopy {
    [CmdletBinding()]
    Param(
        [ValidateNotNullOrEmpty()][string]$SourceConnectionName = "default"
        , [ValidateNotNullOrEmpty()][string]$DestinationConnectionName = "default"
        , [Parameter(Mandatory, ParameterSetName="table")][string]$SourceTable
        , [Parameter(Mandatory, ParameterSetName="query")][AllowEmptyString()][string[]]$SourceQuery
        , [Parameter(ParameterSetName="query")][hashtable]$SourceParameters = @{}
        , [Parameter(ParameterSetName="table")]
            [Parameter(Mandatory, ParameterSetName="query")]
            [string]$DestinationTable
        , [hashtable]$ColumnMap = @{}
        , [ValidateRange(1,25000)][int]$BatchSize = 500
        , [int]$BatchTimeout = -1
        , [switch]$Notify
        , [scriptblock]$NotifyAction
    )
    
    If($SourceConnectionName -eq $DestinationConnectionName) {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                [System.Management.Automation.PSArgumentException]::new(
                    "You cannot use the same connection for both the source and destination!", "SourceConnectionName, DestinationConnectionName"
                ), $null, [System.Management.Automation.ErrorCategory]::InvalidArgument, $null
            )
        )
    }

    If((TestConnectionName -ConnectionName $SourceConnectionName) -and (TestConnectionName -ConnectionName $DestinationConnectionName)) {
        If($BatchTimeout -lt 0) { $BatchTimeout = $script:Connections.$SourceConnectionName.CommandTimeout }
        Try {
            If($PSCmdlet.ParameterSetName -eq "table") {
                If([string]::IsNullOrWhiteSpace($DestinationTable)) { $DestinationTable -eq $SourceTable }
                If($ColumnMap -and $ColumnMap.Count -gt 0) { $SourceQuery = "SELECT {0} FROM $SourceTable" -f $ColumnMap.Keys -join ", " }
                Else { $SourceQuery = "SELECT * FROM $SourceTable" }
            }
            Else { [string]$SourceQuery = $SourceQuery -join [System.Environment]::NewLine }
            
            If(-not $SourceParameters) { $SourceParameters = @{} }
            $srcReader = $script:Connections.$SourceConnectionName.GetReader($SourceQuery, $BatchTimeout, $SourceParameters)
            If($NotifyAction){
                $script:Connections.$DestinationConnectionName.BulkLoad($srcReader, $DestinationTable, $ColumnMap, $BatchSize, $BatchTimeout, $NotifyAction.GetNewClosure())
            }
            ElseIf($Notify.IsPresent) {
                $script:Connections.$DestinationConnectionName.BulkLoad($srcReader, $DestinationTable, $ColumnMap, $BatchSize, $BatchTimeout, {
                        Param([int]$insertCount)
                        Write-Progress -Activity "SimplySql BulkCopy" -Status $DestinationTable -CurrentOperation "Inserted $insertCount rows."
                    }.GetNewClosure())
                Write-Progress -Activity "SimplySql BulkCopy" -Status "Finished" -Completed
            }
            Else { $script:Connections.$DestinationConnectionName.BulkLoad($srcReader, $DestinationTable, $ColumnMap, $BatchSize, $BatchTimeout, $null) }
        }
        Finally {
            If(Test-Path variable:srcReader) { $srcReader.Dispose() }
        }
    }
    Else { Throw [System.Management.Automation.PSArgumentException]::new("Invalid Connection Name(s).", "SourceConnectionName, DestinationConnectionName") }
}

Export-ModuleMember -Function Invoke-SqlBulkCopy