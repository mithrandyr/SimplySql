Describe "PostGre" {
    BeforeEach { Open-PostGreConnection -Server $srvName -Database $db -Credential $c }
    AfterEach { Show-SqlConnection -all | Close-SqlConnection }
    BeforeAll{
        #warm up connection
        $srvName = "xbags"
        $u = "postgres"
        $p = "postgres"
        $db = "postgres"
        $c = [pscredential]::new($u, (ConvertTo-SecureString -Force -AsPlainText $p))
        Open-PostGreConnection -Server $srvName -Database $db -Credential $c
        Close-SqlConnection
    }
    AfterAll {
        Open-PostGreConnection -Server $srvName -Database $db -Credential $c
        Invoke-SqlUpdate "DROP TABLE IF EXISTS transactionTest, tmpTable, tmpTable2, t;"
        Close-SqlConnection
    }

    It "Test ConnectionString Switch" {
        {
            Open-PostGreConnection -ConnectionString "Max Auto Prepare=25;Host=$srvName;Database=$db;Port=5432;Username=$u;password=$p" -ConnectionName Test -ea Stop
            Close-SqlConnection -ConnectionName Test
        } | Should -Not -Throw
    }
    
    It "UserName/Password Are Removed" {
        {
            Open-PostGreConnection -Server $srvName -Database $db -UserName $u -Password $p -ConnectionName test
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
                FROM tally" | Should -Be 65536
    }

    It "Invoke-SqlQuery" {
        Invoke-SqlQuery -Query "SELECT * FROM tmpTable LIMIT 1000" |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be 1000
    }

    It "Invoke-SqlQuery -stream" {
        Invoke-SqlQuery -Query "SELECT * FROM tmpTable LIMIT 1000" -Stream |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be 1000
    }

    It "Invoke-SqlBulkCopy" {
        Invoke-SqlUpdate -Query "SELECT * INTO tmpTable2 FROM tmpTable WHERE 1=2"
        Open-PostGreConnection -Server $srvName -Database $db -ConnectionName bcp -Credential $c
        Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceTable tmpTable -DestinationTable tmpTable2 -Notify |
            Should -Be 65536
        Close-SqlConnection -ConnectionName bcp
    }

    Context "Transaction..." {
        It "Invoke-SqlBulkCopy" {
            Open-PostGreConnection -Server $srvName -Database $db -ConnectionName bcp -Credential $c
            
            Start-SqlTransaction -ConnectionName bcp
            Invoke-SqlUpdate -Query "SELECT * INTO tmpTable3 FROM tmpTable WHERE 1=2" -ConnectionName bcp
            { Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceTable tmpTable -DestinationTable tmpTable3 -Notify |
                Should -Be 65536} | Should -Not -Throw
            Undo-SqlTransaction -ConnectionName bcp

            { Invoke-SqlScalar -ConnectionName bcp -Query "SELECT COUNT(1) FROM tmpTable3" -ea Stop} | Should -Throw
        }

        It "Invoke-SqlScalar" {
            Start-SqlTransaction
            { Invoke-SqlScalar "SELECT 1" -ea Stop} | Should -Not -Throw
            Undo-SqlTransaction
        }

        It "Invoke-SqlQuery" {
            Start-SqlTransaction
            { Invoke-SqlScalar "SELECT 1" -ea Stop} | Should -Not -Throw
            Undo-SqlTransaction
        }

        It "Invoke-SqlUpdate" {
            Start-SqlTransaction
            { Invoke-SqlUpdate "CREATE TABLE transactionTest (id int)" -ea Stop} | Should -Not -Throw
            Undo-SqlTransaction
            { Invoke-SqlScalar "SELECT 1 FROM transactionTest" -ea Stop } | Should -Throw
        }
    }
    
    Context "PipelineInput..." {
        It "Invoke-SqlScalar" {
            {
                [PSCustomObject]@{Name="test"} | Invoke-SqlScalar "SELECT @Name" -ErrorAction Stop
                Get-ChildItem | Invoke-SqlScalar "SELECT @Name " -ErrorAction Stop
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