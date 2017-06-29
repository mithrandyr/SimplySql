<#
.Synopsis
    Undo a sql transaction.

.Description
    Undo (ROLLBACK) a sql transaction.

.Parameter ConnectionName
    User defined name for connection.

#>
Function Undo-SqlTransaction {
    [cmdletBinding()]
    Param([Alias("cn")][string]$ConnectionName = "default")

    If(TestConnectionName -ConnectionName $ConnectionName) {
        $Script:Connections.$ConnectionName.RollbackTransaction()
    }
}

Export-ModuleMember -Function Undo-SqlTransaction