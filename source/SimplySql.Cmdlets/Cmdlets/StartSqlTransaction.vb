Imports System.Management.Automation.Language

<Cmdlet(VerbsLifecycle.Start, "SqlTransaction", SupportsShouldProcess:=True)>
Public Class StartSqlTransaction
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
            If Me.ShouldProcess(ConnectionName, "Create a Sql Transaction") Then
                Try
                    Engine.Logic.GetConnection(ConnectionName).BeginTransaction()
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub
End Class
