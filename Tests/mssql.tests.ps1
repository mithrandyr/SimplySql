Describe "MSSQL" {
    BeforeAll {
        Open-SqlConnection -DataSource "(localdb)\MSSQLLocalDB"
        Invoke-SqlUpdate "IF EXISTS (SELECT * FROM sys.databases WHERE name = 'test') DROP DATABASE test; CREATE DATABASE test" | Should -Be -1
        Close-SqlConnection
    }
    AfterAll {
        Open-SqlConnection -DataSource "(localdb)\MSSQLLocalDB" -Database master
        @(isq "sp_who2" | ? dbname -eq test |% spid).foreach({ isu "KILL $_"})
        Invoke-SqlUpdate "DROP Database Test" | Should -Be -1
        Close-SqlConnection
    }
    BeforeEach { Open-SqlConnection -DataSource "(localdb)\MSSQLLocalDB" }
    AfterEach { Show-SqlConnection -all | Close-SqlConnection }

    It "Test ConnectionString Switch" {
        {
            Open-SqlConnection -ConnectionString "Data Source=(localdb)\MSSQLLocalDB" -ConnectionName Test
            Close-SqlConnection -ConnectionName Test
        } | Should -Not -Throw
    }

    It "Invoke-SqlScalar" {
        Invoke-SqlScalar -Query "SELECT GETDATE()" | Should -BeOfType System.DateTime
    }

    It "Invoke-SqlQuery (No ResultSet Warning)" {
        Invoke-SqlUpdate -Query "CREATE TABLE temp (cola int)"
        Invoke-SqlQuery -Query "INSERT INTO temp VALUES (1)" -WarningAction SilentlyContinue -WarningVariable w
        Invoke-SqlUpdate -Query "DROP TABLE temp"
        $w | Should -BeLike "Query returned no resultset.*"
    }

    It "Invoke-SqlUpdate" {
        Set-SqlConnection -Database "Test"
        Invoke-SqlUpdate -Query ";WITH a(n) AS (SELECT 1 UNION ALL SELECT 1)
            , b(n) AS (SELECT 1 FROM a CROSS JOIN a AS x)
            , c(n) AS (SELECT 1 FROM b CROSS JOIN b AS x)
            , d(n) AS (SELECT 1 FROM c CROSS JOIN c AS x)
            , e(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
            , f(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
            , tally(n) AS (SELECT ROW_NUMBER() OVER (ORDER BY N) FROM f)
            SELECT RAND(n) AS colDec
                , CAST(RAND(n*n / 4) * 1000000 AS int) AS colInt
                , CAST(NEWID() AS VARCHAR(50)) AS colText
            INTO tmpTable
            FROM tally" | Should -Be 65536
    }

    It "Invoke-SqlQuery" {
        Set-SqlConnection -Database "Test"
        Invoke-SqlQuery -Query "SELECT TOP 1000 * FROM tmpTable" |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be 1000
    }

    It "Invoke-SqlQuery -stream" {
        Set-SqlConnection -Database "Test"
        Invoke-SqlQuery -Query "SELECT TOP 1000 * FROM tmpTable" -Stream |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be 1000
    }

    It "Invoke-SqlBulkCopy" {
        Set-SqlConnection -Database "Test"
        Invoke-SqlUpdate -Query "SELECT * INTO tmpTable2 FROM tmpTable WHERE 1=2"
        Open-SqlConnection -DataSource "(localdb)\MSSQLLocalDB" -ConnectionName bcp 
        Set-SqlConnection -Database test -ConnectionName bcp
        
        Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceTable tmpTable -DestinationTable tmpTable2 -Notify |
            Should -Be 65536
        
        Set-SqlConnection -Database master -ConnectionName bcp
        Close-SqlConnection -ConnectionName bcp
    }

    It "Transaction: Invoke-SqlScalar" {
        Start-SqlTransaction
        { Invoke-SqlScalar "SELECT 1" } | Should -Not -Throw
        Undo-SqlTransaction
    }

    It "Transaction: Invoke-SqlQuery" {
        Start-SqlTransaction
        { Invoke-SqlScalar "SELECT 1" } | Should -Not -Throw
        Undo-SqlTransaction
    }

    It "Transaction: Invoke-SqlUpdate" {
        Start-SqlTransaction
        { Invoke-SqlUpdate "CREATE TABLE transactionTest (id int)" -ea Stop } | Should -Not -Throw
        Undo-SqlTransaction
        { Invoke-SqlScalar "SELECT 1 FROM transactionTest" -ea Stop } | Should -Throw
    }
}