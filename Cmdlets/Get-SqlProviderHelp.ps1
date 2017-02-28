
$val = @'
<#
.Synopsis
    Provides Help for SQL providers.

.Description
    Provides Help information for the Providers in the SimplySql module.

.Parameter Provider
    Specifies which provider is being used for this connection.
    Acceptable provider names are:
    <<<LIST>>>

#>
Function Get-SqlProviderHelp {
    [CmdletBinding()]
    Param([Parameter(Mandatory,Position=1)][ValidateSet(<<<LIST>>>)][string]$Provider)
    
    Write-Output ""
    Write-Output ("PROVIDER NAME: {0}" -f ($Script:Providers.Keys | Where-Object {$_ -eq $Provider}))

    Write-Output ""
    Write-Output "SYNOPSIS"
    Write-Output ("    {0}" -f $Script:Providers.$Provider.ShortDescription)
    
    Write-Output ""
    Write-Output "DESCRIPTION"
    Write-Output ("{0}" -f $Script:Providers.$Provider.HelpText)

    Write-Output ""
    Write-Output "PARAMETERS"
    ForEach($kvp in $Script:Providers.$Provider.Parameters.GetEnumerator()) {
        If($kvp.Value.IsSet) { $value = " = {0}" -f $kvp.Value.Value.ToString() } Else { $value = "" }
        Write-Output ("    -{0} <{1}>{2}" -f $kvp.Key, $kvp.Value.ParameterType.Name, $value)
        
        $msg = $kvp.Value.Attributes |
            Where-Object { $_ -Is [System.Management.Automation.ParameterAttribute] -and $_.HelpMessage } |
            Select-Object -First 1 -ExpandProperty HelpMessage
        If($msg) { Write-Output ("        {0}" -f $msg) }
        
        Write-Output ""
    }    
}
'@

$list = '"{0}"' -f ($Script:Providers.Keys -Join '","')

Invoke-Expression $val.Replace("<<<LIST>>>", $list)
Export-ModuleMember -Function Get-SqlProviderHelp
Remove-Variable list, val