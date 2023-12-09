<#
    requires that the predefined account HR is unlocked and has password hr
    using oracle 11.2g Express instance
#>
Describe "Oracle" {
    BeforeEach { Open-OracleConnection -ServiceName xe -Credential ([pscredential]::new("hr", (ConvertTo-SecureString -Force -AsPlainText "hr"))) }
    AfterEach { Show-SqlConnection -all | Close-SqlConnection }
    AfterAll {
        Open-OracleConnection -ServiceName xe -Credential ([pscredential]::new("hr", (ConvertTo-SecureString -Force -AsPlainText "hr")))
        foreach($tbl in @("transactionTest", "tmpTable", "tmpTable2")) {
            $query = "BEGIN
                    EXECUTE IMMEDIATE 'DROP TABLE $tbl';
                EXCEPTION
                    WHEN OTHERS THEN
                    IF SQLCODE != -942 THEN
                        RAISE;
                    END IF;
                END;"
            Invoke-SqlUpdate $query | Out-Null
        }
        Close-SqlConnection
    }

    It "Test ConnectionString Switch" {
        {
            Open-OracleConnection -ConnectionName Test -ConnectionString 'USER ID=hr;PASSWORD=hr;DATA SOURCE="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=xe)))";STATEMENT CACHE SIZE=5;'
            Close-SqlConnection -ConnectionName Test
        } | Should -Not -Throw
    }

    It "UserName/Password Are Removed" {
        {
            Open-OracleConnection -ServiceName xe -UserName hr -Password hr -ConnectionName test
            Close-SqlConnection -ConnectionName test
        } | Should -Throw
    }

    It "Invoke-SqlScalar" {
        Invoke-SqlScalar -Query "SELECT 1 FROM DUAL" | Should -BeOfType System.Decimal
    }

    It "Positional Binding" {
        $result = Invoke-SqlQuery "SELECT :a AS First, :b AS Second, :c AS Third FROM dual" -Parameters @{c="Third";a="First";b="Second"}
        $result.First | Should -Be "First"
        $result.Second | Should -Be "Second"
        $result.Third | Should -Be "Third"
    }

    It "Invoke-SqlQuery (No ResultSet Warning)" {
        Invoke-SqlUpdate -Query "CREATE TABLE temp (cola int)"
        Invoke-SqlQuery -Query "INSERT INTO temp VALUES (1)" -WarningAction SilentlyContinue -WarningVariable w
        Invoke-SqlUpdate -Query "DROP TABLE temp"
        $w | Should -BeLike "Query returned no resultset.*"
    }

    It "Invoke-SqlUpdate" {
        Invoke-SqlUpdate -Query "CREATE TABLE tmpTable (colDec REAL, colInt INTEGER, colText varchar(20))"
        Invoke-SqlUpdate -Query "INSERT INTO tmpTable
            SELECT dbms_random.random /1000000000000. AS colDec
                , dbms_random.random AS colInt
                , dbms_random.string('x',20) AS colText
            FROM dual
            CONNECT BY ROWNUM <= 65536" | Should -Be 65536

        Invoke-SqlUpdate -Query "DROP TABLE tmpTable"            
    }

    It "Invoke-SqlQuery" {
        Invoke-SqlQuery -Query "SELECT dbms_random.random /1000000000000. AS colDec
                , dbms_random.random AS colInt
                , dbms_random.string('x',20) AS colText
            FROM dual
            CONNECT BY ROWNUM <= 1000" |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be 1000
    }

    It "Invoke-SqlQuery -stream" {
        Invoke-SqlQuery -Stream -Query "SELECT dbms_random.random /1000000000000. AS colDec
                , dbms_random.random AS colInt
                , dbms_random.string('x',20) AS colText
            FROM dual
            CONNECT BY ROWNUM <= 1000" |
            Measure-Object |
            Select-Object -ExpandProperty Count |
            Should -Be 1000
    }

    It "Invoke-SqlBulkCopy" -Tag bulkcopy {
        $query = "SELECT dbms_random.random /1000000000000. AS colDec
                , dbms_random.random AS colInt
                , dbms_random.string('x',20) AS colText
            FROM dual
            CONNECT BY ROWNUM <= 65536"
        
        Open-OracleConnection -ConnectionName bcp -ServiceName xe -Credential ([pscredential]::new("hr", (ConvertTo-SecureString -Force -AsPlainText "hr")))
        Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE tmpTable2 (colDec NUMBER(38,10), colInt INTEGER, colText varchar(20))"

        Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable tmpTable2 -Notify |
            Should -Be 65536
        
        Invoke-SqlUpdate -ConnectionName bcp -Query "DROP TABLE tmpTable2"
        Close-SqlConnection -ConnectionName bcp
    }

    It "Invoke-SqlBulkCopy (with transaction)" -Tag bulkcopytransaction {
        $query = "SELECT dbms_random.random /1000000000000. AS colDec
                , dbms_random.random AS colInt
                , dbms_random.string('x',20) AS colText
            FROM dual
            CONNECT BY ROWNUM <= 65536"
        
        Open-OracleConnection -ConnectionName bcp -ServiceName xe -Credential ([pscredential]::new("hr", (ConvertTo-SecureString -Force -AsPlainText "hr")))
        Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE tmpTable2 (colDec NUMBER(38,10), colInt INTEGER, colText varchar(20))"
        Start-SqlTransaction -ConnectionName bcp
        Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable tmpTable2 -Notify |
            Should -Be 65536
        Complete-SqlTransaction -ConnectionName bcp

        Invoke-SqlUpdate -ConnectionName bcp -Query "DROP TABLE tmpTable2"
        Close-SqlConnection -ConnectionName bcp
    }

    It "Transaction: Invoke-SqlScalar" {
        Start-SqlTransaction
        { Invoke-SqlScalar "SELECT 1 FROM dual" -ea Stop} | Should -Not -Throw
        Undo-SqlTransaction
    }

    It "Transaction: Invoke-SqlQuery" {
        Start-SqlTransaction
        { Invoke-SqlScalar "SELECT 1 FROM dual" -ea Stop} | Should -Not -Throw
        Undo-SqlTransaction
    }

    It "Transaction: Invoke-SqlUpdate" {
        Invoke-SqlUpdate "CREATE TABLE transactionTest (id int)"
        Start-SqlTransaction
        { Invoke-SqlUpdate "INSERT INTO transactionTest VALUES (1)" -ea Stop } | Should -Not -Throw
        Undo-SqlTransaction
        Invoke-SqlScalar "SELECT Count(1) FROM transactionTest" | Should -Be 0
        Invoke-SqlUpdate "DROP TABLE transactionTest"
    }
}