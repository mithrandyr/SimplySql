<Cmdlet(VerbsCommon.Clear, "SqlMessage", SupportsShouldProcess:=True)>
Public Class ClearSqlMessage
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
            If Me.ShouldProcess(ConnectionName) Then
                Try
                    Engine.Logic.GetConnection(ConnectionName).ClearMessages()
                    WriteVerbose($"SQL Messages cleared from '{ConnectionName}'.")
                Catch nse As NotSupportedException
                    WriteWarning(nse.Message)
                Catch ex As Exception
                    WriteWarning($"[{ConnectionName}] {ex.Message}")
                End Try
            End If
        End If
    End Sub

End Class
