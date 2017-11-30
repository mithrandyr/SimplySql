<#
    requires that the predefined account HR is unlocked and has password hr
    using oracle 11.2g Express instance
#>
InModuleScope SimplySql {
    Describe "Oracle" {
        BeforeEach { Open-OracleConnection -ServiceName xe -UserName hr -Password hr }
        AfterEach { 
            Show-SqlConnection -all | Close-SqlConnection
         }

        It "Invoke-SqlScalar" {
            Invoke-SqlScalar -Query "SELECT 1 FROM DUAL" | Should BeOfType System.Decimal
        }

        It "Invoke-SqlUpdate" {
            Invoke-SqlUpdate -Query "CREATE TABLE tmpTable (colDec REAL, colInt INTEGER, colText varchar(20))"
            Invoke-SqlUpdate -Query "INSERT INTO tmpTable
                SELECT dbms_random.random /1000000000000. AS colDec
                    , dbms_random.random AS colInt
                    , dbms_random.string('x',20) AS colText
                FROM dual
                CONNECT BY ROWNUM <= 65536" | Should Be 65536

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
                Should Be 1000
        }

        It "Invoke-SqlQuery -stream" {
            Invoke-SqlQuery -Stream -Query "SELECT dbms_random.random /1000000000000. AS colDec
                    , dbms_random.random AS colInt
                    , dbms_random.string('x',20) AS colText
                FROM dual
                CONNECT BY ROWNUM <= 1000" |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                Should Be 1000
        }

        It "Invoke-SqlBulkCopy" {
            $query = "SELECT dbms_random.random /1000000000000. AS colDec
                    , dbms_random.random AS colInt
                    , dbms_random.string('x',20) AS colText
                FROM dual
                CONNECT BY ROWNUM <= 65536"
            
            Open-OracleConnection -ConnectionName bcp -ServiceName xe -UserName hr -Password hr
            Invoke-SqlUpdate -ConnectionName bcp -Query "CREATE TABLE tmpTable2 (colDec REAL, colInt INTEGER, colText varchar(20))"

            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceQuery $query -DestinationTable tmpTable2 -Notify |
                Should Be 65536
            
            Invoke-SqlUpdate -ConnectionName bcp -Query "DROP TABLE tmpTable2"
            Close-SqlConnection -ConnectionName bcp
       }

       It "Dropping Tables" {
            Try { Invoke-SqlUpdate "DROP TABLE tmpTable" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP TABLE tmpTable2" | Out-Null } Catch {}
            1 | Should Be 1            
       }
    }
}