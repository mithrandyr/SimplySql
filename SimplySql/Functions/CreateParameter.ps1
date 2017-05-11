Function CreateParameter {
    Param([string]$Name
        , [type]$Type
        , [System.Management.Automation.ParameterAttribute[]]$Parameters = @()
        , [hashtable[]]$ParameterHashes = @()
        , [string[]]$ValidateSet = @()
        , [string[]]$Alias = @()
        , [object]$DefaultValue)

    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
    
    $Parameters | ForEach-Object { $AttributeCollection.Add($_) }
    $ParameterHashes | ForEach-Object { $AttributeCollection.Add((CreateParameterAttribute @_)) }

    If($ValidateSet.Count -gt 0) { $AttributeCollection.Add([System.Management.Automation.ValidateSetAttribute]::new($ValidateSet)) }
    If($Alias.Count -gt 0) { $AttributeCollection.Add([System.Management.Automation.AliasAttribute]::new($Alias)) }

    $parameter = [System.Management.Automation.RuntimeDefinedParameter]::new($Name, $Type, $AttributeCollection)
    If($DefaultValue) { $parameter.Value = $DefaultValue }
    Return $parameter
}