<#
.Synopsis
    Complete a sql transaction.

.Description
    Complete (COMMIT) a sql transaction.

.Parameter ConnectionName
    User defined name for connection.

#>
Function Complete-SqlTransaction {
    [cmdletBinding()]
    Param([Parameter(Position=0)][ValidateNotNullOrEmpty()][Alias("cn")][string]$ConnectionName = "default")

    If(TestConnectionName -ConnectionName $ConnectionName) {
        try { $Script:Connections.$ConnectionName.CommitTransaction() }
        catch {
            Write-Warning "Received an error while Completing the transaction, usually this means a timeout has expire and you can safely ignore: $_."
            if($Script:Connections.$ConnectionName.Transaction) {
                $Script:Connections.$ConnectionName.Transaction.Dispose()
                $Script:Connections.$ConnectionName.Transaction = $null
            }
            if($Script:Connections.$ConnectionName.Connection.State -eq "Closed") { $Script:Connections.$ConnectionName.Connection.Open() }
        }
    }

}

Export-ModuleMember -Function Complete-SqlTransaction