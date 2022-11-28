Imports System.Management.Automation.Language

<Cmdlet(VerbsCommon.Get, "SqlMessage", SupportsShouldProcess:=True)>
Public Class GetSqlMessage
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"
#End Region

    Protected Overrides Sub ProcessRecord()
        If Not Engine.Logic.ConnectionExists(ConnectionName) Then
            WriteError(ConnectionNotFoundError(ConnectionName))
        Else
            If Me.ShouldProcess(ConnectionName, "Get Sql Messages") Then
                Dim conn = Engine.Logic.GetConnection(ConnectionName)
                Try
                    Do While conn.HasMessages
                        WriteObject(conn.GetMessage)
                    Loop
                Catch nse As NotSupportedException
                    WriteWarning(nse.Message)
                Catch ex As Exception
                    WriteError(New ErrorRecord(ex, MyInvocation.MyCommand.Name, ErrorCategory.InvalidOperation, ConnectionName))
                End Try
            End If
        End If
    End Sub
End Class
