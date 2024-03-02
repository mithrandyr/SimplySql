Describe "MySql" {
    BeforeAll {
        $srvName = "xbags"
        $u = "root"
        $p = "root"
        $db = "mysql"
        $c = [pscredential]::new($u, (ConvertTo-SecureString -Force -AsPlainText $p))

        Open-MySqlConnection -Server $srvName -Database $db -Credential $c
        Invoke-SqlUpdate -Query "CREATE OR REPLACE VIEW $db.generator_16
            AS SELECT 0 n UNION ALL SELECT 1  UNION ALL SELECT 2  UNION ALL 
            SELECT 3   UNION ALL SELECT 4  UNION ALL SELECT 5  UNION ALL
            SELECT 6   UNION ALL SELECT 7  UNION ALL SELECT 8  UNION ALL
            SELECT 9   UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
            SELECT 12  UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL 
            SELECT 15;

            CREATE OR REPLACE VIEW $db.generator_256
            AS SELECT ( ( hi.n << 4 ) | lo.n ) AS n
                FROM $db.generator_16 lo, $db.generator_16 hi;

            CREATE OR REPLACE VIEW $db.generator_64k
            AS SELECT ( ( hi.n << 8 ) | lo.n ) AS n
                FROM $db.generator_256 lo, $db.generator_256 hi;" | Out-Null
        Close-SqlConnection
    }
    AfterAll {
        Open-MySqlConnection -Server $srvName -Database $db -Credential $c
        Invoke-SqlUpdate "DROP TABLE IF EXISTS transactionTest;
                        DROP TABLE IF EXISTS $db.tmpTable;
                        DROP TABLE IF EXISTS $db.tmpTable2;
                        DROP TABLE IF EXISTS $db.tmpTable3;
                        DROP VIEW IF EXISTS $db.generator_64k;
                        DROP VIEW IF EXISTS $db.generator_256;
                        DROP VIEW IF EXISTS $db.generator_16;"
        Close-SqlConnection
    }
    BeforeEach { Open-MySqlConnection -Server $srvName -Database $db -Credential $c }
    AfterEach { Show-SqlConnection -all | Close-SqlConnection }

    It "Test ConnectionString Switch " {
        {
            Open-MySqlConnection -ConnectionString "server=$srvName;database=$db;port=3306;user id=$u;password=$p;useaffectedrows=True;allowuservariables=True;sslmode=none" -ConnectionName Test -ea Stop
            Close-SqlConnection -ConnectionName Test
        } | Should -Not -Throw
    }

    It "UserName/Password Are Removed" {
        {
            Open-MySqlConnection -Server $srvName -UserName $u -Password $p -Database $db -ConnectionName test
            Close-SqlConnection -ConnectionName test
        } | Should -Throw
    }

    It "Invoke-SqlScalar" {
        Invoke-SqlScalar -Query "SELECT Now()" | Should -BeOfType System.DateTime
    }

    It "Invoke-SqlQuery (No ResultSet Warning)" {
        Invoke-SqlUpdate -Query "CREATE TABLE temp (cola int)"
        Invoke-SqlQuery -Query "INSERT INTO temp VALUES (1)" -WarningAction SilentlyContinue -WarningVariable w
        Invoke-SqlUpdate -Query "DROP TABLE temp"
        $w | Should -BeLike "Query returned no resultset.*"
    }

    It "Invoke-SqlUpdate" {
        Invoke-SqlUpdate -Query "
            CREATE TABLE $db.tmpTable (colDec REAL, colInt Int, colText varchar(36));
            INSERT INTO $db.tmpTable
                SELECT rand() AS colDec
                    , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                    , uuid() AS colText
                FROM $db.generator_64k" | Should -Be 65536
        
    }

    It "Invoke-SqlQuery" {
        Invoke-SqlQuery -Query "
            SELECT rand() AS colDec
                , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                , uuid() AS colText
            FROM $db.generator_64k
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
            FROM $db.generator_64k
            LIMIT 1000" -Stream |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be 1000
    }

    It "Invoke-SqlBulkCopy" {
        $query = "SELECT rand() AS colDec
                , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                , uuid() AS colText
            FROM $db.generator_64k"
        
        Open-MySqlConnection -ConnectionName bcp -Server $srvName -Database mysql -Credential $c
        Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE $db.tmpTable2 (colDec REAL, colInt INTEGER, colText TEXT)"

        Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable "$db.tmpTable2" -Notify |
            Should -Be 65536
    }

    Context "Transaction..." {
        It "Invoke-SqlBulkCopy" {
            $query = "SELECT rand() AS colDec
                    , CAST(rand() * 1000000000 AS SIGNED) AS colInt
                    , uuid() AS colText
                FROM $db.generator_64k"
            
            Open-MySqlConnection -ConnectionName bcp -Server $srvName -Database mysql -Credential $c
            
            Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE $db.tmpTable3 (colDec REAL, colInt INTEGER, colText TEXT)"
            Start-SqlTransaction bcp
            
            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable "$db.tmpTable3" -Notify | Should -Be 65536
            Invoke-SqlScalar -Query "SELECT COUNT(1) FROM $db.tmpTable3" -cn bcp | Should -Be 65536

            Undo-SqlTransaction bcp
            Invoke-SqlScalar -Query "SELECT COUNT(1) FROM $db.tmpTable3" -cn bcp | Should -Be 0
        }

        It "Invoke-SqlScalar" {
            Start-SqlTransaction
            { Invoke-SqlScalar "SELECT 1" -ea Stop } | Should -Not -Throw
            Undo-SqlTransaction
        }

        It "Invoke-SqlQuery" {
            Start-SqlTransaction
            { Invoke-SqlScalar "SELECT 1" -ea Stop} | Should -Not -Throw
            Undo-SqlTransaction
        }

        It "Invoke-SqlUpdate" {
            Invoke-SqlUpdate "CREATE TABLE transactionTest (id int)"
            Start-SqlTransaction
            { Invoke-SqlUpdate "INSERT INTO transactionTest VALUES (1)" -ea Stop} | Should -Not -Throw
            Undo-SqlTransaction
            Invoke-SqlScalar "SELECT Count(1) FROM transactionTest" | Should -Be 0
            Invoke-SqlUpdate "DROP TABLE transactionTest"
        }
    }
    
    Context "PipelineInput..." {
        It "Invoke-SqlScalar" {
            {
                [PSCustomObject]@{Name="test"} | Invoke-SqlScalar "SELECT @Name" -ErrorAction Stop
                Get-ChildItem | Invoke-SqlScalar "SELECT @Name" -ErrorAction Stop
            } | Should -Not -Throw
        }

        It "Invoke-SqlQuery" {
            {
                [PSCustomObject]@{Name="test"} | Invoke-SqlQuery "SELECT @Name" -ErrorAction Stop
                Get-ChildItem | Invoke-SqlQuery "SELECT @Name" -ErrorAction Stop
            } | Should -Not -Throw
        }

        It "Invoke-SqlScalar" {
            {
                Invoke-SqlUpdate "CREATE TABLE t(x varchar(255))" -ErrorAction Stop
                [PSCustomObject]@{Name="test"} | Invoke-SqlUpdate "INSERT INTO t SELECT @Name" -ErrorAction Stop
                Get-ChildItem | Invoke-SqlScalar "INSERT INTO t SELECT @Name"-ErrorAction Stop
                Invoke-SqlUpdate "DROP TABLE t" -ErrorAction Stop
            } | Should -Not -Throw
        }
    }
    
    Context "Validations..." {
        It "Handles JSON as PSObject" {
            Invoke-SqlScalar "SELECT @json" -Parameters @{json = (1..5 | ConvertTo-Json -Compress)} | Should -Be "[1,2,3,4,5]"
        }
    }
}

<#
    http://use-the-index-luke.com/blog/2011-07-30/mysql-row-generator#mysql_generator_code
#>