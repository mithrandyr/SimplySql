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
    Param([string]$ConnectionName = "default")

    If(TestConnectionName -ConnectionName $ConnectionName) {
        $Script:Connections.$ConnectionName.CommitTransaction()
    }

}

Export-ModuleMember -Function Complete-SqlTransaction