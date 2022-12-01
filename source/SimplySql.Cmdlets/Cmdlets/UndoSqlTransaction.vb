Imports System.Management.Automation.Language

<Cmdlet(VerbsCommon.Undo, "SqlTransaction", SupportsShouldProcess:=True)>
Public Class UndoSqlTransaction
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
            If Me.ShouldProcess(ConnectionName, "Rollback a Sql Transaction") Then
                Try
                    Engine.Logic.GetConnection(ConnectionName).RollbackTransaction()
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub
End Class
