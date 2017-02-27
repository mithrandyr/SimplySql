$Config = [ProviderConfig]::new()

$Config.HelpText = @"
    Microsoft SQL Server (System.Data.SqlClient)

"@

$Config.CreateProvider = {
    Param([hashtable]$ht)

}

$Config.ShortDescription = "Microsoft SQL Server (System.Data.SqlClient)"


#$Config.Parameters.Add()


Write-Output $Config