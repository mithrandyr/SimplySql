Write-Output ([ProviderConfig]::new(
    "SQLite (System.Data.SQLite)",
    @"
SQLite (System.Data.SQLite)
"@,
    @(
        @{Name = "DataSource"
            Type = [string]
            ParameterHashes = @(
                @{
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "The datasource for the connection."
                }
            )
            Alias = "FilePath"
            DefaultValue = ":memory:"
        },
        @{Name = "Password"
            Type = [string]
            ParameterHashes = @(
                @{
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "Password for the database file."
                }
            )
        }
    ),
    { Param([hashtable]$ht) return [SQLiteProvider]::New($ht.ConnectionName, $ht.CommandTimeout, [SQLiteProvider]::CreateConnection($ht)) }
))
