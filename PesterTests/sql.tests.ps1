InModuleScope SimplySql {
    Describe "Provider: SQL" {
        BeforeEach { Open-SqlConnection -Provider SQL -DataSource "(localdb)\MSSQLLocalDB" }
        AfterEach { Close-SqlConnection }

        It "Create a Test Database" {
            Invoke-SqlUpdate "Create Database Test" | Should Be -1
        }

        It "Invoke-SqlScalar" {
            Invoke-SqlScalar -Query "SELECT GETDATE()" | Should BeOfType System.DateTime
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
                FROM tally" | Should Be 65536
        }

        It "Invoke-SqlQuery" {
            Set-SqlConnection -Database "Test"
            Invoke-SqlQuery -Query "SELECT TOP 1000 * FROM tmpTable" |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should Be 1000
        }

        It "Invoke-SqlQuery -stream" {
            Set-SqlConnection -Database "Test"
            Invoke-SqlQuery -Query "SELECT TOP 1000 * FROM tmpTable" -Stream |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should Be 1000
        }

        It "Invoke-SqlBulkCopy" {
            Set-SqlConnection -Database "Test"
            Invoke-SqlUpdate -Query "SELECT * INTO tmpTable2 FROM tmpTable WHERE 1=2"
            Open-SqlConnection -Provider SQL -DataSource "(localdb)\MSSQLLocalDB" -ConnectionName conn2 -InitialCatalog Test
            
            Invoke-SqlBulkCopy -DestinationConnectionName conn2 -SourceTable tmpTable -DestinationTable tmpTable2 |
                Should Be 65536
            
            Close-SqlConnection -ConnectionName conn2
        }

        It "Remove the Test Database" {
            Show-SqlConnection -All | Where-Object { $_ -ne "default"} | Close-SqlConnection
            Invoke-SqlUpdate "drop Database Test" | Should Be -1
        }

    }
}