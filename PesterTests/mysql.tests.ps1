<#
    http://use-the-index-luke.com/blog/2011-07-30/mysql-row-generator#mysql_generator_code
#>
InModuleScope SimplySql {
    Describe "MySql" {
        BeforeEach { Open-MySqlConnection -UserName root -Password password -Database sys }
        AfterEach { 
            Show-SqlConnection -all | Close-SqlConnection
         }
        
        It "Creating Views" {
            Invoke-SqlUpdate -Query "CREATE OR REPLACE VIEW sys.generator_16
                AS SELECT 0 n UNION ALL SELECT 1  UNION ALL SELECT 2  UNION ALL 
                SELECT 3   UNION ALL SELECT 4  UNION ALL SELECT 5  UNION ALL
                SELECT 6   UNION ALL SELECT 7  UNION ALL SELECT 8  UNION ALL
                SELECT 9   UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
                SELECT 12  UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL 
                SELECT 15;

                CREATE OR REPLACE VIEW sys.generator_256
                AS SELECT ( ( hi.n << 4 ) | lo.n ) AS n
                    FROM sys.generator_16 lo, sys.generator_16 hi;

                CREATE OR REPLACE VIEW sys.generator_64k
                AS SELECT ( ( hi.n << 8 ) | lo.n ) AS n
                    FROM sys.generator_256 lo, sys.generator_256 hi;" | Out-Null
            1 | Should Be 1
        }

        It "Invoke-SqlScalar" {
            Invoke-SqlScalar -Query "SELECT Now()" | Should BeOfType System.DateTime
        }

        It "Invoke-SqlUpdate" {
            Invoke-SqlUpdate -Query "
                CREATE TABLE sys.tmpTable (colDec REAL, colInt Int, colText varchar(36));
                INSERT INTO sys.tmpTable
                    SELECT rand() AS colDec
                        , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                        , uuid() AS colText
                    FROM sys.generator_64k" | Should Be 65536
            
        }

        It "Invoke-SqlQuery" {
            Invoke-SqlQuery -Query "
                SELECT rand() AS colDec
                    , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                    , uuid() AS colText
                FROM sys.generator_64k
                LIMIT 1000" |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should Be 1000
        }

        It "Invoke-SqlQuery -stream" {
            Invoke-SqlQuery -Query "
                SELECT rand() AS colDec
                    , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                    , uuid() AS colText
                FROM sys.generator_64k
                LIMIT 1000" -Stream |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should Be 1000
        }

        It "Invoke-SqlBulkCopy" {
            $query = "SELECT rand() AS colDec
                    , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                    , uuid() AS colText
                FROM sys.generator_64k"
            
            Open-MySqlConnection -ConnectionName bcp -UserName root -Password password -Database sys 
            Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE sys.tmpTable2 (colDec REAL, colInt INTEGER, colText TEXT)"

            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable "sys.tmpTable2" -Notify |
                Should Be 65536
            
            Close-SqlConnection -ConnectionName bcp
       }

       It "Dropping Tables, Views" {
            Try { Invoke-SqlUpdate "DROP TABLE sys.tmpTable" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP TABLE sys.tmpTable2" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP VIEW sys.generator_64k" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP VIEW sys.generator_256" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP VIEW sys.generator_16" | Out-Null } Catch {}
            1 | Should Be 1            
       }
    }
}