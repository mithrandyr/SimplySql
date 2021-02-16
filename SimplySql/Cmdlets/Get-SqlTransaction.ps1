<#
.Synopsis
    Gets the underlying transaction object.

.Description
    Gets the underlying transaction object for the current connection
    or for the connection name specified.

.Parameter ConnectionName
    User Defined name for the SqlConnection.

#>
Filter Get-SqlTransaction {
    [CmdletBinding()]
    Param([parameter(ParameterSetName="single", ValueFromPipeline, Position=0)][ValidateNotNullOrEmpty()][Alias("cn")][string]$ConnectionName = "default")
    
    If(-not (TestConnectionName $ConnectionName)) { return }
    Else { $Script:Connections.$ConnectionName.Transaction | Write-Output }
        
}
Export-ModuleMember -Function Get-SqlTransaction