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
                    HelpMessage = "The datasource for the connection."
                },
                @{
                    ParameterSetName = "user"
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "The datasource for the connection."
                },
                @{
                    ParameterSetName = "cred"
                    ValueFromPipelineByPropertyName = $true
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
                    HelpMessage = "Database catalog to connect to."
                },
                @{
                    ParameterSetName = "user"
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "Database catalog to connect to."
                },
                @{
                    ParameterSetName = "cred"
                    ValueFromPipelineByPropertyName = $true
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
        },
        @{Name = "Credential"
            Type = [pscredential]
            ParameterHashes = @(
                @{
                    ParameterSetName = "cred"
                    Mandatory = $true
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "Credential object containing the SQL user/pass."
                },
                @{
                    ParameterSetName = "Conn"
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "Credential object containing the SQL user/pass."
                }
            )
        }
    ),
    { Param([hashtable]$ht) return [SQLProvider]::New($ht.ConnectionName, $ht.CommandTimeout, [SQLProvider]::CreateConnection($ht)) }
))
