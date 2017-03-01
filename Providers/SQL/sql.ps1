Write-Output ([ProviderConfig]::new(
    "Microsoft SQL Server (System.Data.SqlClient)",
    @"
Microsoft SQL Server (System.Data.SqlClient)
"@,
    @(
        @{Name = "DataSource"
            Type = [string]
            ParameterHashes = @(
                @{
                    ValueFromPipelineByPropertyName = $true
                    Position = 1
                    HelpMessage = "The datasource for the connection."
                },
                @{
                    ParameterSetName = "user"
                    ValueFromPipelineByPropertyName = $true
                    Position = 1
                    HelpMessage = "The datasource for the connection."
                }
            )
            Alias = "SqlInstance"
            DefaultValue = "localhost"
        },
        @{Name = "InitialCatalog"
            Type = [string]
            ParameterHashes = @(
                @{
                    ValueFromPipelineByPropertyName = $true
                    Position = 2
                    HelpMessage = "Database catalog to connect to."
                },
                @{
                    ParameterSetName = "user"
                    ValueFromPipelineByPropertyName = $true
                    Position = 2
                    HelpMessage = "Database catalog to connect to."
                }            
            )
            Alias = "SqlDatabase"
            DefaultValue = "master"
        },
        @{Name = "User"
            Type = [string]
            ParameterHashes = @(
                @{
                    ParameterSetName = "user"
                    Mandatory = $true
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "Username to connect as."
                }
            )
        },
        @{Name = "Password"
            Type = [string]
            ParameterHashes = @(
                @{
                    ParameterSetName = "user"
                    Mandatory = $true
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "Password for the user connecting as."
                }
            )
        }
    ),
    {
    Param([hashtable]$ht)

    return [SQLProvider]::New()
}))
