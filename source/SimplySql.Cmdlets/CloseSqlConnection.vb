<Cmdlet(VerbsCommon.Close, "SqlConnection", SupportsShouldProcess:=True)>
<[Alias]("csc")>
Public Class CloseSqlConnection
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"
#End Region

    Protected Overrides Sub ProcessRecord()
        If Not Engine.Logic.ConnectionExists(ConnectionName) Then
            WriteVerbose($"Cannot close the SQL Connection '{ConnectionName}' because it does not exist.")
        Else
            If Me.ShouldProcess(ConnectionName) Then
                Dim conn = Engine.Logic.GetConnection(ConnectionName)
                If conn.HasTransaction Then conn.RollbackTransaction()
                Try
                    conn.Connection.Close()
                Finally
                    conn.Connection.Dispose()
                    Engine.Logic.RemoveConnection(conn.ConnectionName)
                End Try
                WriteVerbose($"SQL Connection '{ConnectionName}' closed.")
            End If
        End If
    End Sub
End Class
