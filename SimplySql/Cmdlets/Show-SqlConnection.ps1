<#
.Synopsis
    Lists the current or all SqlConnections.

.Description
    Lists the current SqlConnection information or outputs a list of all
    SqlConnections currently active.

.Parameter ConnectionName
    User Defined name for the SqlConnection.

.Parameter All
    Returns a list of names for all active SqlConnections.

#>
Filter Show-SqlConnection {
    [CmdletBinding()]
    Param([parameter(ParameterSetName="single", ValueFromPipeline, Position=0)][ValidateNotNullOrEmpty()][Alias("cn")][string]$ConnectionName = "default"
        , [parameter(ParameterSetName="all", Mandatory)][switch]$All)
    
    If($All.IsPresent) {
        [string[]]$keys = $Script:Connections.Keys | ForEach-Object { $_ }
        if($keys) { $keys | Write-Output }        
    }
    Else {
        If(-not (TestConnectionName $ConnectionName)) { return }
        Else { $Script:Connections.$ConnectionName.ConnectionInfo() | Write-Output }
    }
    
}
Set-Alias -Name ssc -Value Show-SqlConnection
Export-ModuleMember -Function Show-SqlConnection -Alias ssc