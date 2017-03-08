
$val = @'
<#
.Synopsis
    Open a connection to a database server.

.Description
    Open a connection to a database server.
    Supports:
        <<<DESCRIPTION>>>

.Parameter ConnectionName
    The name to associate with the newly created connection.
    This connection will be used with other cmdlets when specifying
    -ConnectionName <name>.  If you don't specify one, it will be
    set to the default.

.Parameter Provider
    Specifies which provider is being used for this connection.
    Acceptable provider names are:
    <<<LIST>>>

    The command Get-SqlProviderHelp provides information on the additional
    parameters available to be used.

.Parameter ConnectionString
    Specifies a provider specific connectionstring to be used.

#>
Function Open-SqlConnection {
    [CmdletBinding(DefaultParameterSetName="default")]
    Param([Alias("cn")][string]$ConnectionName = "default"
        , [int]$CommandTimeout = 30
        , [ValidateSet(<<<LIST>>>)][string]$Provider
        , [Parameter(Mandatory, ParameterSetName="Conn")][string]$ConnectionString)
    
    DynamicParam {
        If(-not $PSBoundParameters.ContainsKey("Provider") -and $Script:Providers.ContainsKey("SQL")) { $PSBoundParameters["Provider"] = "SQL" }

        $pName = $PSBoundParameters["Provider"]
        If($Script:Providers.$pName.Parameters.Count -gt 0) { Return $Script:Providers.$pName.Parameters }
    }
    
    End {
        If($Script:Connections.ContainsKey($ConnectionName)) {
            [string]$errorMessage = "Connection is already opened!  Please close it by running Close-SqlConnection."
            If($ConnectionName -ne "default") {
                $errorMessage = "Connection '{0}' is already opened!  Please close it by running Close-SqlConnection -ConnectionName {0}" -f $ConnectionName
            }

            Write-Error -Exception [System.Data.DuplicateNameException]::New($errorMessage), $null, [System.Management.Automation.ErrorCategory]::InvalidArgument, $null -ErrorAction Stop
        }
        Else {
            $PSBoundParameters.ParameterSetName = $PSCmdlet.ParameterSetName
            $PSBoundParameters.ConnectionName = $ConnectionName
            $PSBoundParameters.CommandTimeout = $CommandTimeout
            $PSBoundParameters = $PSBoundParameters | AddDynamicParameterDefaults
            
            $Script:Connections.$ConnectionName = $Script:Providers.$pName.CreateProvider.Invoke($PSBoundParameters)
        }
    }
}
'@

$desc = @()
$list = '"{0}"' -f ($Script:Providers.Keys -Join '","')
$Script:Providers.Keys |
    ForEach-Object {
        If([string]::IsNullOrWhiteSpace($Script:Providers.$_.ShortDescription)) { $desc += $_ }
        Else { $desc += $Script:Providers.$_.ShortDescription }
    }

$desc = $desc -join "`n        "

$val = $val.Replace("<<<DESCRIPTION>>>", $desc).Replace("<<<LIST>>>", $list)

Invoke-Expression $val
Set-Alias -Name osc -Value Open-SqlConnection
Export-ModuleMember -Function Open-SqlConnection -Alias osc
Remove-Variable list, val, desc