Write-Output ([ProviderConfig]::new(
    "Oracle (Oracle.ManagedDataAccess)",
    @"
    Oracle (Oracle.ManagedDataAccess)
    
    Oracle Managed Data Access @ http://www.oracle.com/technetwork/topics/dotnet/index-085163.html
    .NET Provider @ https://www.nuget.org/packages/Oracle.ManagedDataAccess/
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
            DefaultValue = "localhost"
        },
        @{Name = "ServiceName"
            Type = [string]
            ParameterHashes = @(
                @{
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "Oracle ServiceName (SID)"
                }
            )
            Mandatory = $true
        },
        @{Name = "Port"
            Type = [int]
            ParameterHashes = @(
                @{
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "Port to connect on, defaults to 1521"
                }
            )
            DefaultValue = 1521
        },
        @{Name = "User"
            Type = [string]
            ParameterHashes = @(
                @{
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "User to authenticate as."
                }
            )
            Mandatory = $true
        },
        @{Name = "Password"
            Type = [string]
            ParameterHashes = @(
                @{
                    ValueFromPipelineByPropertyName = $true
                    HelpMessage = "Password for the user."
                }
            )
            Mandatory = $true
        },
        @{Name = "DBAPrivilege"
            Type = [string]
            ParameterHashes = @(
                @{ HelpMessage = "Specifies the DBA Privilege option on the connection, must be SYSDBA or SYSOPER" }
            )
            ValidateSet = @("SYSDBA", "SYSOPER")
        }
    ),
    { Param([hashtable]$ht) return [OracleProvider]::New($ht.ConnectionName, $ht.CommandTimeout, [OracleProvider]::CreateConnection($ht)) }
))
