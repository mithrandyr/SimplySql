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
                Dim conn = Engine.Logic.GetConnection(ConnectionName)
                Try
                    conn.CommitTransaction()
                Catch ex As Exception
                    If conn.Connection.State = Data.ConnectionState.Closed Then conn.Connection.Open()
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub
End Class
