InModuleScope SimplySql {
    Describe "Provider: PostGre" {
        BeforeEach { Open-PostGreConnection -Database postgres -UserName postgres -password password }
        AfterEach { Close-SqlConnection }

        It "Warmup Connection" { $true | Should Be True }
        
        It "Invoke-SqlScalar" {
            Invoke-SqlScalar -Query "SELECT Now()" | Should BeOfType System.DateTime
        }

        It "Invoke-SqlUpdate" {
            Invoke-SqlUpdate -Query "CREATE TABLE tmpTable (colDec decimal, colInt Int, colText varchar(50))"
            Invoke-SqlUpdate -Query ";WITH a(n) AS (SELECT 1 UNION ALL SELECT 1)
                , b(n) AS (SELECT 1 FROM a CROSS JOIN a AS x)
                , c(n) AS (SELECT 1 FROM b CROSS JOIN b AS x)
                , d(n) AS (SELECT 1 FROM c CROSS JOIN c AS x)
                , e(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
                , f(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
                , tally(n) AS (SELECT ROW_NUMBER() OVER (ORDER BY N) FROM f)
                INSERT INTO tmpTable
                    SELECT random() AS colDec
                        , CAST(random() * 1000000 AS int) AS colInt
                        , CAST(Random() AS VARCHAR(50)) AS colText                
                    FROM tally" | Should Be 65536
        }

        It "Invoke-SqlQuery" {
            Invoke-SqlQuery -Query "SELECT * FROM tmpTable LIMIT 1000" |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should Be 1000
        }

        It "Invoke-SqlQuery -stream" {
            Invoke-SqlQuery -Query "SELECT * FROM tmpTable LIMIT 1000" -Stream |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should Be 1000
        }

        It "Invoke-SqlBulkCopy" {
            Invoke-SqlUpdate -Query "SELECT * INTO tmpTable2 FROM tmpTable WHERE 1=2"
            Open-PostGreConnection -Database postgres -UserName postgres -password password -ConnectionName bcp 
            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceTable tmpTable -DestinationTable tmpTable2 -Notify |
                Should Be 65536
            Close-SqlConnection -ConnectionName bcp
        }

        It "Dropping Tables" {
            Try { Invoke-SqlUpdate "DROP TABLE tmpTable" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP TABLE tmpTable2" | Out-Null } Catch {}
            1 | Should Be 1            
       }
    }
}