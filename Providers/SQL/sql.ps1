
$Config = [ProviderConfig]::new()
$Config.ShortDescription = "Microsoft SQL Server (System.Data.SqlClient)"
$Config.HelpText = @"
Microsoft SQL Server (System.Data.SqlClient)
"@

#DataSource Parameter
$ht = @{Name = "DataSource"
        Type = [string]
        Parameters = @(
            (CreateParameterAttribute -ValueFromPipelineByPropertyName -Position 1 -HelpMessage "The datasource for the connection.")
            , (CreateParameterAttribute -ParameterSetName user -ValueFromPipelineByPropertyName -Position 1 -HelpMessage "The datasource for the connection.")
        )
        Alias = "SqlInstance"
        DefaultValue = "localhost"
    }
$Config.Parameters.Add($ht.Name, (CreateParameter @ht))

#InitialCatalog Parameter
$ht = @{Name = "InitialCatalog"
        Type = [string]
        Parameters = @(
            (CreateParameterAttribute -ValueFromPipelineByPropertyName -Position 2 -HelpMessage "Database catalog to connect to.")
            , (CreateParameterAttribute -ParameterSetName user -ValueFromPipelineByPropertyName -Position 2 -HelpMessage "Database catalog to connect to.")
        )
        Alias = "SqlDatabase"
        DefaultValue = "master"
    }
$Config.Parameters.Add($ht.Name, (CreateParameter @ht))

#User Parameter
$ht = @{Name = "User"
        Type = [string]
        Parameters = @(
            CreateParameterAttribute -ParameterSetName user -Mandatory -ValueFromPipelineByPropertyName -HelpMessage "Username to connect as."
        )
    }
$Config.Parameters.Add($ht.Name, (CreateParameter @ht))
#Password Parameter
$ht = @{Name = "Password"
        Type = [string]
        Parameters = @(
            CreateParameterAttribute -ParameterSetName user -Mandatory -ValueFromPipelineByPropertyName -HelpMessage "Password for the user connecting as."
        )
    }
$Config.Parameters.Add($ht.Name, (CreateParameter @ht))

$Config.CreateProvider = {
    Param([hashtable]$ht)

}
#$host.EnterNestedPrompt()
Write-Output $Config

Remove-Variable config, ht #, p