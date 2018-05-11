InModuleScope SimplySql {
    Describe "SQLite" {
        BeforeEach { Open-SQLiteConnection }
        AfterEach { Show-SqlConnection -all | Close-SqlConnection }
        
        It "Test ConnectionString Switch" {
            {
                Open-SQLiteConnection -ConnectionString "Data Source=:memory:" -ConnectionName Test
                Close-SqlConnection -ConnectionName Test
            } | Should Not Throw
        }
        It "Invoke-SqlScalar" {
            Invoke-SqlScalar -Query "SELECT 1" | Should BeOfType System.Int64
        }

        It "Invoke-SqlQuery (No ResultSet Warning)" {
            Invoke-SqlUpdate -Query "CREATE TABLE temp (cola int)"
            $WarningPreference = "stop"
            Try { Invoke-SqlQuery -Query "INSERT INTO temp VALUES (1)" }
            Catch { $val = $_.ToString() }
            Finally { Invoke-SqlUpdate -Query "DROP TABLE temp" }
            $val | Should Be "The running command stopped because the preference variable `"WarningPreference`" or common parameter is set to Stop: Query returned no resultset.  This occurs when the query has no select statement or invokes a stored procedure that does not return a resultset.  Use 'Invoke-SqlUpdate' to avoid this warning."
        }

        It "Invoke-SqlUpdate" {
            Invoke-SqlUpdate -Query "
            CREATE TABLE tmpTable (colDec REAL, colInt INTEGER, colText TEXT)
            ;WITH a(n) AS (SELECT 1 UNION ALL SELECT 1)
                    , b(n) AS (SELECT 1 FROM a CROSS JOIN a AS x)
                    , c(n) AS (SELECT 1 FROM b CROSS JOIN b AS x)
                    , d(n) AS (SELECT 1 FROM c CROSS JOIN c AS x)
                    , e(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
                    , f(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
                INSERT INTO tmpTable
                    SELECT random()/1000000000000. AS colDec
                        , random() AS colInt
                        , hex(randomblob(20)) AS colText
                    FROM f" | Should Be 65536
            
            Invoke-SqlUpdate -Query "DROP TABLE tmpTable" | Out-Null
        }

        It "Invoke-SqlQuery" {
            Invoke-SqlQuery -Query "WITH a(n) AS (SELECT 1 UNION ALL SELECT 1)
                    , b(n) AS (SELECT 1 FROM a CROSS JOIN a AS x)
                    , c(n) AS (SELECT 1 FROM b CROSS JOIN b AS x)
                    , d(n) AS (SELECT 1 FROM c CROSS JOIN c AS x)
                    , e(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
                    , f(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
                SELECT random()/1000000000000. AS colDec
                    , random() AS colInt
                    , hex(randomblob(20)) AS colText
                FROM f
                LIMIT 1000" |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should Be 1000
        }

        It "Invoke-SqlQuery -stream" {
            Invoke-SqlQuery -Query "WITH a(n) AS (SELECT 1 UNION ALL SELECT 1)
                    , b(n) AS (SELECT 1 FROM a CROSS JOIN a AS x)
                    , c(n) AS (SELECT 1 FROM b CROSS JOIN b AS x)
                    , d(n) AS (SELECT 1 FROM c CROSS JOIN c AS x)
                    , e(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
                    , f(n) AS (SELECT 1 FROM d CROSS JOIN d AS x)
                SELECT random()/1000000000000. AS colDec
                    , random() AS colInt
                    , hex(randomblob(20)) AS colText
                FROM f
                LIMIT 1000" -Stream |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should Be 1000
        }

        It "Invoke-SqlBulkCopy" {
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
            
            Open-SQLiteConnection -ConnectionName bcp -DataSource "$home\temp.db"
            Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE tmpTable (colDec REAL, colInt INTEGER, colText TEXT)"

            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable tmpTable -Notify |
                Should Be 65536
            
            Close-SqlConnection -ConnectionName bcp
       }

       It "Remove File" { { Remove-Item "$home\temp.db" } | Should Not Throw }
    }
}