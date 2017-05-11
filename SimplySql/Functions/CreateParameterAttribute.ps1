Function CreateParameterAttribute {
    Param([string]$ParameterSetName = "default"
        , [switch]$Mandatory
        , [int]$Position = 0
        , [switch]$ValueFromPipeline
        , [switch]$ValueFromPipelineByPropertyName
        , [switch]$ValueFromRemainingArguments
        , [string]$HelpMessage)
    
    $attribute = [System.Management.Automation.ParameterAttribute]::new()
    $attribute.ParameterSetName = $ParameterSetName
    $attribute.Mandatory = $Mandatory.IsPresent    
    $attribute.Position = $Position
    $attribute.ValueFromPipeline = $ValueFromPipeline.IsPresent
    $attribute.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName.IsPresent
    $attribute.ValueFromRemainingArguments = $ValueFromRemainingArguments.IsPresent
    If(-not [string]::IsNullOrWhiteSpace($HelpMessage)) { $attribute.HelpMessage = $HelpMessage }
    
    Write-Output $attribute
}