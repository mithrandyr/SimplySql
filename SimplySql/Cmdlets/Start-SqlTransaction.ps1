<#
.Synopsis
    Start a sql transaction.

.Description
    Start (BEGIN) a sql transaction.

.Parameter ConnectionName
    User defined name for connection.

#>
Function Start-SqlTransaction {
    [cmdletBinding()]
    Param([string]$ConnectionName = "default")

    If(TestConnectionName -ConnectionName $ConnectionName) {
        $Script:Connections.$ConnectionName.BeginTransaction()
    }

}

Export-ModuleMember -Function Start-SqlTransaction