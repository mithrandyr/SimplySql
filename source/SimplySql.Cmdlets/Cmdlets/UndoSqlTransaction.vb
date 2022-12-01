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
                Dim conn = Engine.Logic.GetConnection(ConnectionName)
                Try
                    conn.RollbackTransaction()
                Catch ex As Exception
                    If conn.Connection.State = Data.ConnectionState.Closed Then conn.Connection.Open()
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub
End Class
