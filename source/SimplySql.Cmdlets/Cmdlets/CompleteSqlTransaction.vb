Imports System.Management.Automation.Language

<Cmdlet(VerbsLifecycle.Complete, "SqlTransaction", SupportsShouldProcess:=True)>
Public Class CompleteSqlTransaction
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"
#End Region

    Protected Overrides Sub ProcessRecord()
        If Not Engine.Logic.ConnectionExists(ConnectionName) Then
            ErrorConnectionNotFound(ConnectionName)
        Else
            If Me.ShouldProcess(ConnectionName, "Commit a Sql Transaction") Then
                Try
                    Engine.Logic.GetConnection(ConnectionName).CommitTransaction()
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub
End Class
