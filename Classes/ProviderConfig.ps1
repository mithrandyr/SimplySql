Class ProviderConfig {
    [string]$ShortDescription
    [string]$HelpText
    [scriptblock]$CreateProvider
    [hashtable[]]$ParameterHash
    [System.Management.Automation.RuntimeDefinedParameterDictionary]$Parameters = (New-Object System.Management.Automation.RuntimeDefinedParameterDictionary)

    ProviderConfig() {}
    
    ProviderConfig([string]$ShortDescription, [string]$HelpText, [hashtable[]]$ht, [scriptblock]$CreateProvider){
        $this.ShortDescription = $ShortDescription
        $this.HelpText = $HelpText
        $this.ParameterHash = $ht
        $this.CreateProvider = $CreateProvider
    }

    [System.Management.Automation.RuntimeDefinedParameterDictionary] GenerateParameters() {
        $paramDict = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
        ForEach($ht in $this.ParameterHash) { $paramDict.Add($ht.name, (CreateParameter @ht)) }
        Return $ParamDict        
    }
}
