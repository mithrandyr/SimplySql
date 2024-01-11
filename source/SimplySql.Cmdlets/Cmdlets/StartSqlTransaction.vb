<Cmdlet(VerbsLifecycle.Start, "SqlTransaction", SupportsShouldProcess:=True)>
Public Class StartSqlTransaction
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True, ValueFromPipeline:=True, Position:=0)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    <PSDefaultValue(Value:="default")>
    Public Property ConnectionName As String = "default"
#End Region

    Protected Overrides Sub ProcessRecord()
        If ValidateConnection(ConnectionName) Then
            If Me.ShouldProcess(ConnectionName, "Begin a Sql Transaction") Then
                Try
                    Engine.Logic.GetConnection(ConnectionName).BeginTransaction()
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub
End Class
