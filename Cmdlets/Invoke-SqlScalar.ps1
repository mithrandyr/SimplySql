<#
#>
Function Invoke-SqlScalar {
    [CmdletBinding()]
    Param([Parameter(Mandatory)][string[]]$Query
        , [hashtable]$Parameters = @{}
        , [int]$CommandTimeout = -1
        , [string]$ConnectionName = "default")
    
    If(TestConnectionName -ConnectionName $ConnectionName) {
        [string]$Query = $Query -join [System.Environment]::NewLine
        Write-Output $Script:Connections.$ConnectionName.GetScalar($Query, $CommandTimeout, $Parameters)
    }
}

Set-Alias -Name iss -Value Invoke-SqlScalar
Export-ModuleMember -Function Invoke-SqlScalar -Alias iss