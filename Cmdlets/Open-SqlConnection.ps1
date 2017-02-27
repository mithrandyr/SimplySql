
$val = @'
<#
.Synopsis
    Open a connection to a database server.

.Description
    Open a connection to a database server.
    Supports:
        <<<DESCRIPTION>>>

#>
Function Open-SqlConnection {
    [CmdletBinding()]
    Param([Alias("cn")][string]$ConnectionName = "default"
        , [ValidateSet(<<<LIST>>>)][string]$Provider)
    
    DynamicParam {

    }
    
    End {
        If($Script:Connections.ContainsKey($ConnectionName)) {
            [string]$errorMessage = "Connection is already opened!  Please close it by running Close-SqlConnection."
            If($ConnectionName -ne "default") {
                $errorMessage = "Connection '{0}' is already opened!  Please close it by running Close-SqlConnection -ConnectionName {0}" -f $ConnectionName
            }

            Write-Error -Exception [System.Data.DuplicateNameException]::New($errorMessage), $null, [System.Management.Automation.ErrorCategory]::InvalidArgument, $null -ErrorAction Stop
        }
    }
}
'@

$desc = @()
$list = '"{0}"' -f ($Script:Providers.Keys -Join '","')
ForEach($key in $Script:Providers.Keys) {
    If([string]::IsNullOrWhiteSpace($Script:Providers.$key.ShortDescription)) { $desc += $key }
    Else { $desc += $Script:Providers.$key.ShortDescription }
}
$desc = $desc -join "`n        "

$val = $val.Replace("<<<DESCRIPTION>>>", $desc).Replace("<<<LIST>>>", $list)

Invoke-Expression $val
Export-ModuleMember -Function Open-SqlConnection