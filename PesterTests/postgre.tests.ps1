InModuleScope SimplySql {
    Describe "PostGre" {
        BeforeEach { Open-PostGreConnection -Database postgres -Credential ([pscredential]::new("postgres", (ConvertTo-SecureString -Force -AsPlainText "postgres"))) }
        AfterEach { Show-SqlConnection -all | Close-SqlConnection }

        It "Warmup Connection" { $true | Should -Be True }

        It "Test ConnectionString Switch" {
            {
                Open-PostGreConnection -ConnectionString "Max Auto Prepare=25;Host=localhost;Database=postgres;Port=5432;Username=postgres;password=postgres" -ConnectionName Test
                Close-SqlConnection -ConnectionName Test
            } | Should -Not -Throw
        }
        
        It "Test UserName/Password Parameters" {
            {
                Open-PostGreConnection -Database postgres -UserName postgres -Password postgres -ConnectionName test
                Close-SqlConnection -ConnectionName test
            } | Should -Not -Throw
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
            Open-PostGreConnection -Database postgres -ConnectionName bcp -Credential ([pscredential]::new("postgres", (ConvertTo-SecureString -Force -AsPlainText "postgres")))
            Invoke-SqlBulkCopy -DestinationConnectionName bcp -SourceTable tmpTable -DestinationTable tmpTable2 -Notify |
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
            Start-SqlTransaction
            { Invoke-SqlUpdate "CREATE TABLE transactionTest (id int)" } | Should -Not -Throw
            Undo-SqlTransaction
            { Invoke-SqlScalar "SELECT 1 FROM transactionTest" } | Should -Throw
        }
        
        It "Dropping Tables" {
            Try { Invoke-SqlUpdate "DROP TABLE transactionTest" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP TABLE tmpTable" | Out-Null } Catch {}
            Try { Invoke-SqlUpdate "DROP TABLE tmpTable2" | Out-Null } Catch {}
            1 | Should -Be 1            
       }

        It "Test ProviderTypes" {
            $Query = @"
                SELECT
                5 AS "Int",
                'foo' AS "String",
                NOW() AS "DateTime",
                NOW() AT TIME ZONE 'Universal' AS "DateTimeNoZone",
                DATE(NOW()) AS "Date"
"@
            function Test-Type {
                param (
                    $Response,
                    [Switch]$ProviderTypes
                )
                $Response.Int            | Should -BeOfType 'Int'
                $Response.String         | Should -BeOfType 'String'
                if ($ProviderTypes) {
                    $Response.DateTime            | Should -BeOfType 'NpgsqlTypes.NpgsqlDateTime'
                    $Response.DateTime.Kind	      | Should -Be       'Local'
                    $Response.DateTimeNoZone      | Should -BeOfType 'NpgsqlTypes.NpgsqlDateTime'
                    $Response.DateTimeNoZone.Kind | Should -Be       'Unspecified'
                    $Response.Date                | Should -BeOfType 'NpgsqlTypes.NpgsqlDate'
                }
                else {
                    $Response.DateTime       | Should -BeOfType 'DateTime'
                    $Response.DateTimeNoZone | Should -BeOfType 'DateTime'
                    $Response.Date           | Should -BeOfType 'DateTime'
                }
            }

            Test-Type -Response (Invoke-SqlQuery -Query $Query)
            Test-Type -Response (Invoke-SqlQuery -Query $Query -Stream)
            Test-Type -Response (Invoke-SqlQuery -Query $Query -ProviderTypes) -ProviderTypes
            Test-Type -Response (Invoke-SqlQuery -Query $Query -ProviderTypes -Stream) -ProviderTypes
        }
    }
}