<Cmdlet(VerbsCommon.Get, "SqlMessage", SupportsShouldProcess:=True)>
Public Class GetSqlMessage
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True, ValueFromPipeline:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    <PSDefaultValue(Value:="default")>
    Public Property ConnectionName As String = "default"
#End Region

    Protected Overrides Sub ProcessRecord()
        If ValidateConnection(ConnectionName) Then
            If Me.ShouldProcess(ConnectionName, "Get Sql Messages") Then
                Dim conn = Engine.Logic.GetConnection(ConnectionName)
                Try
                    Do While conn.HasMessages
                        WriteObject(conn.GetMessage)
                    Loop
                Catch nse As NotSupportedException
                    WriteWarning(nse.Message)
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub
End Class
