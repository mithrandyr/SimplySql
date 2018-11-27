<#
.Synopsis
    Gets the underlying provider connection object.

.Description
    Gets the underlying provider connection object for the current connection
    or for the connection name specified.

.Parameter ConnectionName
    User Defined name for the SqlConnection.

#>
Filter Get-SqlConnection {
    [CmdletBinding()]
    Param([parameter(ParameterSetName="single", ValueFromPipeline, Position=0)][ValidateNotNullOrEmpty()][Alias("cn")][string]$ConnectionName = "default")
    
    If(-not (TestConnectionName $ConnectionName)) { return }
    Else { $Script:Connections.$ConnectionName.Connection | Write-Output }
        
}
Set-Alias -Name gsc -Value Get-SqlConnection
Export-ModuleMember -Function Get-SqlConnection -Alias gsc