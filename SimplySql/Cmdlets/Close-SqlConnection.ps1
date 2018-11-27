<#
.Synopsis
    Closes an existing connection.

.Description
    Closes the connection and disposes of the underlying object.
    This will also rollback the current transaction if there is one.

.Parameter ConnectionName
    User Defined name for the SqlConnection.

#>
Filter Close-SqlConnection {
    [CmdletBinding()]
    Param([parameter(ValueFromPipeline, Position=0)][ValidateNotNullOrEmpty()][Alias("cn")][string]$ConnectionName = "default")
    
    If(-not (TestConnectionName $ConnectionName)) { return }
    Else {
        If($Script:Connections.$ConnectionName.HasTransaction()) {
            $Script:Connections.$ConnectionName.RollbackTransaction()
        }
        Try { $Script:Connections.$ConnectionName.Connection.Close() }
        Finally {
            $Script:Connections.$ConnectionName.Connection.Dispose()
            $Script:Connections.Remove($ConnectionName)
        }        
    }    
}

Set-Alias -Name csc -Value Close-SqlConnection
Export-ModuleMember -Function Close-SqlConnection -Alias csc