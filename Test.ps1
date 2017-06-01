[cmdletBinding()]
Param([switch]$Load)
Write-Host "PID: $pid"
If($Load) {
    $cmd = "{0}" -f $PSCmdlet.MyInvocation.MyCommand.Source
    PowerShell -noprofile -noexit -command $cmd
}
Else {
    #Clear-Host
    Write-Host "In New PowerShell Session, [exit] to resume."
    $PSModuleAutoLoadingPreference = "none"
    Import-Module $PSScriptRoot\SimplySql -Force
    Import-Module Pester -Force

    Invoke-Pester -Script $PSScriptRoot #-TestName "Provider: SQLite"

    <#Get-Module SimplySql | Format-List

    Get-SqlProviderHelp -Provider SQL
    Get-SqlProviderHelp -Provider SQLite

    Open-SqlConnection -DataSource it4 -InitialCatalog sandbox 

    Show-SqlConnection

    isq "select @a" -Parameters @{a=1}

    Get-SqlProviderHelp -Provider SQL

    #>
}

<#
Import-Module ..\onedrive\windowspowershell\moduledevelopment\simplysql\simplysql
Open-SqlConnection -Provider SQLite
$query = "WITH a(n) AS (SELECT 1 UNION ALL SELECT 1)
        , b(n) AS (SELECT 1 FROM a CROSS JOIN a AS x)
        , c(n) AS (SELECT 1 FROM b CROSS JOIN b AS x)
        , d(n) AS (SELECT 1 FROM c CROSS JOIN c AS x)
        , e(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
        , f(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
    SELECT random()/1000000000000. AS colDec
        , random() AS colInt
        , hex(randomblob(20)) AS colText
    FROM f"

Open-SqlConnection -Provider SQLite -ConnectionName bcp -DataSource "$home\temp\new.db"
Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE tmpTable (colDec REAL, colInt INTEGER, colText TEXT)"

Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable tmpTable -Notify |
    Should Be 65536

Close-SqlConnection -ConnectionName bcp
Close-SqlConnection

#>