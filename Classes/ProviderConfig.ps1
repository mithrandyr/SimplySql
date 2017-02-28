Class ProviderConfig {
    [string]$ShortDescription
    [string]$HelpText
    [scriptblock]$CreateProvider
    [System.Management.Automation.RuntimeDefinedParameterDictionary]$Parameters = (New-Object System.Management.Automation.RuntimeDefinedParameterDictionary)
}
