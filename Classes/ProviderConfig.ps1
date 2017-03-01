Class ProviderConfig {
    [string]$ShortDescription
    [string]$HelpText
    [scriptblock]$CreateProvider
    [System.Management.Automation.RuntimeDefinedParameterDictionary]$Parameters = (New-Object System.Management.Automation.RuntimeDefinedParameterDictionary)

    ProviderConfig() {}
    
    ProviderConfig([string]$ShortDescription, [string]$HelpText, [hashtable[]]$ht, [scriptblock]$CreateProvider){
        $this.ShortDescription = $ShortDescription
        $this.HelpText = $HelpText
        $ht | ForEach-Object { $this.Parameters.Add($_.name, (CreateParameter @_)) }
        $this.CreateProvider = $CreateProvider
    }
}
