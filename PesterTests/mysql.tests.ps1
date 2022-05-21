<#
    http://use-the-index-luke.com/blog/2011-07-30/mysql-row-generator#mysql_generator_code
#>
InModuleScope SimplySql {
    Describe "MySql" {
        BeforeEach { Open-MySqlConnection -Database mysql -Credential ([pscredential]::new("root", (ConvertTo-SecureString -Force -AsPlainText "root"))) }
        AfterEach { Show-SqlConnection -all | Close-SqlConnection }
        
        It "Test ConnectionString Switch " {
            {
                Open-MySqlConnection -ConnectionString "server=localhost;database=mysql;port=3306;user id=root;password=root;useaffectedrows=True;allowuservariables=True;sslmode=none" -ConnectionName Test
                Close-SqlConnection -ConnectionName Test
            } | Should -Not -Throw
        }

        It "Test UserName/Password Parameters" {
            {
                Open-MySqlConnection -UserName root -Password root -Database mysql -ConnectionName test
                Close-SqlConnection -ConnectionName test
            } | Should -Not -Throw
        }

        It "Creating Views" {
            Invoke-SqlUpdate -Query "CREATE OR REPLACE VIEW mysql.generator_16
                AS SELECT 0 n UNION ALL SELECT 1  UNION ALL SELECT 2  UNION ALL 
                SELECT 3   UNION ALL SELECT 4  UNION ALL SELECT 5  UNION ALL
                SELECT 6   UNION ALL SELECT 7  UNION ALL SELECT 8  UNION ALL
                SELECT 9   UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
                SELECT 12  UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL 
                SELECT 15;

                CREATE OR REPLACE VIEW mysql.generator_256
                AS SELECT ( ( hi.n << 4 ) | lo.n ) AS n
                    FROM mysql.generator_16 lo, mysql.generator_16 hi;

                CREATE OR REPLACE VIEW mysql.generator_64k
                AS SELECT ( ( hi.n << 8 ) | lo.n ) AS n
                    FROM mysql.generator_256 lo, mysql.generator_256 hi;" | Out-Null
            1 | Should -Be 1
        }

        It "Invoke-SqlScalar" {
            Invoke-SqlScalar -Query "SELECT Now()" | Should -BeOfType System.DateTime
        }

        It "Invoke-SqlQuery (No ResultSet Warning)" {
            Invoke-SqlUpdate -Query "CREATE TABLE temp (cola int)"
            $WarningPreference = "stop"
            Try { Invoke-SqlQuery -Query "INSERT INTO temp VALUES (1)" }
            Catch { $val = $_.ToString() }
            Finally { Invoke-SqlUpdate -Query "DROP TABLE temp" }
            $val | Should -Be "The running command stopped because the preference variable `"WarningPreference`" or common parameter is set to Stop: Query returned no resultset.  This occurs when the query has no select statement or invokes a stored procedure that does not return a resultset.  Use 'Invoke-SqlUpdate' to avoid this warning."
        }

        It "Invoke-SqlUpdate" {
            Invoke-SqlUpdate -Query "
                CREATE TABLE mysql.tmpTable (colDec REAL, colInt Int, colText varchar(36));
                INSERT INTO mysql.tmpTable
                    SELECT rand() AS colDec
                        , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                        , uuid() AS colText
                    FROM mysql.generator_64k" | Should -Be 65536
            
        }

        It "Invoke-SqlQuery" {
            Invoke-SqlQuery -Query "
                SELECT rand() AS colDec
                    , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                    , uuid() AS colText
                FROM mysql.generator_64k
                LIMIT 1000" |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should -Be 1000
        }

        It "Invoke-SqlQuery -stream" {
            Invoke-SqlQuery -Query "
                SELECT rand() AS colDec
                    , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                    , uuid() AS colText
                FROM mysql.generator_64k
                LIMIT 1000" -Stream |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should -Be 1000
        }

        It "Invoke-SqlBulkCopy" {
            $query = "SELECT rand() AS colDec
                    , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                    , uuid() AS colText
                FROM mysql.generator_64k"
            
            Open-MySqlConnection -ConnectionName bcp -Database mysql -Credential ([pscredential]::new("root", (ConvertTo-SecureString -Force -AsPlainText "root")))
            Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE mysql.tmpTable2 (colDec REAL, colInt INTEGER, colText TEXT)"

            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable "mysql.tmpTable2" -Notify |
                Should -Be 65536

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
            Invoke-SqlUpdate "CREATE TABLE transactionTest (id int)"
            Start-SqlTransaction
            { Invoke-SqlUpdate "INSERT INTO transactionTest VALUES (1)" } | Should -Not -Throw
            Undo-SqlTransaction
            Invoke-SqlScalar "SELECT Count(1) FROM transactionTest" | Should -Be 0
            Invoke-SqlUpdate "DROP TABLE transactionTest"
        }

        It "Dropping Tables, Views" {
            Try { Invoke-SqlUpdate "DROP TABLE transactionTest" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP TABLE mysql.tmpTable" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP TABLE mysql.tmpTable2" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP VIEW mysql.generator_64k" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP VIEW mysql.generator_256" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP VIEW mysql.generator_16" | Out-Null } Catch {}
            1 | Should -Be 1            
        }
    }
}