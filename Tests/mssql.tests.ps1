$ErrorActionPreference
Describe "MSSQL" {
    BeforeAll {
        $srvName = "xbags\SQLEXPRESS"
        $c = [pscredential]::new("simplysql", (ConvertTo-SecureString -Force -AsPlainText "simplysql"))
        $connHT = @{
            DataSource = $srvName
            Credential = $c
        }
        
        Open-SqlConnection @connHT
        Invoke-SqlUpdate "IF EXISTS (SELECT * FROM sys.databases WHERE name = 'test') DROP DATABASE test; CREATE DATABASE test" | Should -Be -1
        Close-SqlConnection
    }
    AfterAll {
        Open-SqlConnection @connHT -Database master
        @(isq "sp_who2" | ? dbname -eq test | % spid).foreach({ isu "KILL $_" })
        Invoke-SqlUpdate "DROP Database Test" | Should -Be -1
        Close-SqlConnection
    }
    BeforeEach { Open-SqlConnection @connHT -Database "test" }
    AfterEach { Show-SqlConnection -all | Close-SqlConnection }

    It "Test ConnectionString Switch" {
        {
            $connStr = "Data Source=$srvName;TrustServerCertificate=true"
            if ($connHT.ContainsKey("Credential")) {
                Open-SqlConnection -ConnectionString $connStr -ConnectionName Test -Credential $connHT.Credential -ErrorAction Stop
            }
            else {
                Open-SqlConnection -ConnectionString "$connStr;Integrated Security=SSPI" -ConnectionName Test -ErrorAction Stop
            }

            Close-SqlConnection -ConnectionName Test
        } | Should -Not -Throw
    }

    It "Test Integrated Security" {
        if ($PSVersionTable.PSEdition -eq "Desktop" -or $PSVersionTable.Platform -like "Win*") {
            {
                Open-SqlConnection -Server $srvName -ConnectionName "Test" -ErrorAction Stop
                Close-SqlConnection -ConnectionName "Test"                
            } | Should -Not -Throw
        }
        else {
            Set-ItResult -Skipped -Because "Environment does not support Windows Integrated Auth"
        }
        
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
        Invoke-SqlQuery -Query "SELECT TOP 1000 * FROM tmpTable" |
        Measure-Object |
        Select-Object -ExpandProperty Count |
        Should -Be 1000
    }
    
    It "Invoke-SqlQuery (with Primary Key)" {
        Invoke-SqlUpdate -Query "CREATE TABLE #tmpPK (col1 varchar(25), col2 int, PRIMARY KEY (col1, col2));" | Out-Null
        Invoke-SqlUpdate -Query "INSERT INTO #tmpPK SELECT 'A', 1" | Out-Null
        Invoke-SqlUpdate -Query "INSERT INTO #tmpPK SELECT 'A', 2" | Out-Null
        Invoke-SqlUpdate -Query "INSERT INTO #tmpPK SELECT 'B', 3" | Out-Null

        Invoke-SqlQuery -Query "SELECT col1 FROM #tmpPK" |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be 3
    }

    It "Invoke-SqlQuery (multiple columns of same name)" {
        $val = Invoke-SqlQuery "SELECT 1 AS a, 2 AS a, 3 AS a"
        $val.a | Should -Be 1
        $val.a1 | Should -Be 2
        $val.a2 | Should -Be 3
    }

    It "Invoke-SqlQuery (multiple columns of same name) -stream" {
        $val = Invoke-SqlQuery "SELECT 1 AS a, 2 AS a, 3 AS a" -Stream
        $val.a | Should -Be 1
        $val.a1 | Should -Be 2
        $val.a2 | Should -Be 3
    }

    It "Invoke-SqlQuery -stream" {
        Invoke-SqlQuery -Query "SELECT TOP 1000 * FROM tmpTable" -Stream |
        Measure-Object |
        Select-Object -ExpandProperty Count |
        Should -Be 1000
    }

    It "Invoke-SqlBulkCopy" {
        Invoke-SqlUpdate -Query "SELECT * INTO tmpTable2 FROM tmpTable WHERE 1=2"
        Open-SqlConnection @connHT -ConnectionName bcp 
        Set-SqlConnection -Database test -ConnectionName bcp
        
        Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceTable tmpTable -DestinationTable tmpTable2 |
        Should -Be 65536
    }

    It "Invoke-SqlBulkCopy (with -Notify)" {
        Invoke-SqlUpdate -Query "SELECT * INTO tmpTable20 FROM tmpTable WHERE 1=2"
        Open-SqlConnection @connHT -ConnectionName bcp 
        Set-SqlConnection -Database test -ConnectionName bcp
        
        Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceTable tmpTable -DestinationTable tmpTable2 -Notify |
        Should -Be 65536
    }
    
    It "Invoke-SqlBulkCopy (with -NotifyAction)" {
        Invoke-SqlUpdate -Query "SELECT * INTO tmpTable10 FROM tmpTable WHERE 1=2"
        Open-SqlConnection @connHT -ConnectionName bcp 
        Set-SqlConnection -Database test -ConnectionName bcp
        
        $result = @{val = 0}
        Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceTable tmpTable -DestinationTable tmpTable2 -NotifyAction {param($rows) $result.val = $rows }
        $result.val | Should -Be 65536
    }


    Context "Transaction..." {
        It "Invoke-SqlBulkCopy" {
            Open-SqlConnection @connHT -ConnectionName bcp -Database test

            Start-SqlTransaction -ConnectionName bcp    
            Invoke-SqlUpdate -Query "SELECT * INTO tmpTable3 FROM tmpTable WHERE 1=2" -ConnectionName bcp
            { Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceTable tmpTable -DestinationTable tmpTable3 -Notify -ea Stop |
                Should -Be 65536 } | Should -Not -Throw
            Undo-SqlTransaction -ConnectionName bcp
            
            { Invoke-SqlScalar -Query "SELECT COUNT(1) FROM tmpTable3" -ea Stop } | Should -Throw
        }

        It "Invoke-SqlScalar" {
            Start-SqlTransaction
            { Invoke-SqlScalar "SELECT 1" -ea Stop } | Should -Not -Throw
            Undo-SqlTransaction
        }

        It "Invoke-SqlQuery" {
            Start-SqlTransaction
            { Invoke-SqlScalar "SELECT 1" -ea Stop } | Should -Not -Throw
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
            Invoke-SqlScalar "SELECT @json" -Parameters @{json = (1..5 | ConvertTo-Json -Compress)} | Should -Be "[1,2,3,4,5]"
        }
    }
}