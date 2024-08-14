Describe "SQLite" {
    BeforeEach { Open-SQLiteConnection }
    AfterEach { Show-SqlConnection -all | Close-SqlConnection }
    AfterAll {
        Remove-Item "$home\temp.db"        
    }
    
    It "Test ConnectionString Switch" {
        {
            Open-SQLiteConnection -ConnectionString "Data Source=:memory:" -ConnectionName Test -ea Stop
            Close-SqlConnection -ConnectionName Test
        } | Should -Not -Throw
    }
    
    It "Invoke-SqlScalar" {
        Invoke-SqlScalar -Query "SELECT 1" | Should -BeOfType System.Int64
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
                FROM f" | Should -Be 65536
        
        Invoke-SqlUpdate -Query "DROP TABLE tmpTable" | Out-Null
    }
    
    Context "Invoke-SqlQuery" {
        It "No ResultSet Warning" {
            Invoke-SqlUpdate -Query "CREATE TABLE temp (cola int)"
            Invoke-SqlQuery -Query "INSERT INTO temp VALUES (1)" -WarningAction SilentlyContinue -WarningVariable w
            Invoke-SqlUpdate -Query "DROP TABLE temp"
            $w | Should -BeLike "Query returned no resultset.*"
        }
        It "Normal" {
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
            Should -Be 1000
        }
    
        It "With Primary Key" {
            Invoke-SqlUpdate -Query "CREATE TABLE tmpPK (col1 varchar(25), col2 int, PRIMARY KEY (col1, col2));" | Out-Null
            Invoke-SqlUpdate -Query "INSERT INTO tmpPK SELECT 'A', 1" | Out-Null
            Invoke-SqlUpdate -Query "INSERT INTO tmpPK SELECT 'A', 2" | Out-Null
            Invoke-SqlUpdate -Query "INSERT INTO tmpPK SELECT 'B', 3" | Out-Null

            Invoke-SqlQuery -Query "SELECT col1 FROM tmpPK" |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be 3
        }

        It "Multiple columns of same name" {
            $val = Invoke-SqlQuery "SELECT 1 AS a, 2 AS a, 3 AS a"
            $val.a | Should -Be 1
            $val.a1 | Should -Be 2
            $val.a2 | Should -Be 3
        }

        It "Multiple columns of same name With -stream" {
            $val = Invoke-SqlQuery "SELECT 1 AS a, 2 AS a, 3 AS a" -Stream
            $val.a | Should -Be 1
            $val.a1 | Should -Be 2
            $val.a2 | Should -Be 3
        }

        It "With -stream" {
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
            Should -Be 1000
        }
    }
    Context "Invoke-SqlBulkCopy" {
        It "Normal" {
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

            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable tmpTable |
            Should -Be 65536
        
            Close-SqlConnection -ConnectionName bcp
        }

        It "With -Notify" {
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
            Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE tmpTable21 (colDec REAL, colInt INTEGER, colText TEXT)"

            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable tmpTable21 -Notify |
            Should -Be 65536
        
            Close-SqlConnection -ConnectionName bcp
        }

        It "With -NotifyAction" {
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
            Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE tmpTable22 (colDec REAL, colInt INTEGER, colText TEXT)"

            $result = @{val = 0 }
            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable tmpTable22 -NotifyAction { param($rows) $result.val = $rows }
            $result.val | Should -Be 65536
        
            Close-SqlConnection -ConnectionName bcp
        }
    }
    
    Context "PipelineInput..." {
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
        
            Start-SqlTransaction -ConnectionName bcp
            Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE tmpTable3 (colDec REAL, colInt INTEGER, colText TEXT)"
            { Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable tmpTable3 -Notify |
                Should -Be 65536 } | Should -Not -Throw
            Undo-SqlTransaction -ConnectionName bcp

            { Invoke-SqlScalar -ConnectionName bcp -Query "SELECT COUNT(1) FROM tmpTable3" -ea Stop } | Should -Throw
        }


        It "Invoke-SqlScalar" {
            Start-SqlTransaction
            { Invoke-SqlScalar "SELECT 1" } | Should -Not -Throw
            Undo-SqlTransaction
        }

        It "Invoke-SqlQuery" {
            Start-SqlTransaction
            { Invoke-SqlScalar "SELECT 1" } | Should -Not -Throw
            Undo-SqlTransaction
        }

        It "Invoke-SqlUpdate" {
            Start-SqlTransaction
            { Invoke-SqlUpdate "CREATE TABLE transactionTest (id int)" -ea Stop } | Should -Not -Throw
            Undo-SqlTransaction
            { Invoke-SqlScalar "SELECT 1 FROM transactionTest" -ea Stop } | Should -Throw
        }
    }
    
    Context "PipelineInput..." {
        It "Invoke-SqlScalar" {
            {
                [PSCustomObject]@{Name = "test" } | Invoke-SqlScalar "SELECT @Name" -ErrorAction Stop
                Get-ChildItem | Invoke-SqlScalar "SELECT @Name" -ErrorAction Stop
            } | Should -Not -Throw
        }

        It "Invoke-SqlQuery" {
            {
                [PSCustomObject]@{Name = "test" } | Invoke-SqlQuery "SELECT @Name" -ErrorAction Stop
                Get-ChildItem | Invoke-SqlQuery "SELECT @Name" -ErrorAction Stop
            } | Should -Not -Throw
        }

        It "Invoke-SqlScalar" {
            {
                Invoke-SqlUpdate "CREATE TABLE t(x varchar(255))" -ErrorAction Stop
                [PSCustomObject]@{Name = "test" } | Invoke-SqlUpdate "INSERT INTO t SELECT @Name" -ErrorAction Stop
                Get-ChildItem | Invoke-SqlScalar "INSERT INTO t SELECT @Name"-ErrorAction Stop
                Invoke-SqlUpdate "DROP TABLE t" -ErrorAction Stop
            } | Should -Not -Throw
        }
    }

    Context "Validations..." {
        It "Handles JSON as PSObject" {
            Invoke-SqlScalar "SELECT @json" -Parameters @{json = (1..5 | ConvertTo-Json -Compress) } | Should -Be "[1,2,3,4,5]"
        }
    }
}