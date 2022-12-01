Imports System.Management.Automation.Language

<Cmdlet(VerbsCommon.Set, "SqlConnection", SupportsShouldProcess:=True)>
Public Class SetSqlConnection
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"

    <Parameter(Position:=0, ValueFromPipelineByPropertyName:=True)>
    Public Property Database As String

    <Parameter(ValueFromPipelineByPropertyName:=True)>
    Public Property CommandTimeout As Integer = -1
#End Region

    Protected Overrides Sub ProcessRecord()
        If Not Engine.Logic.ConnectionExists(ConnectionName) Then
            ErrorConnectionNotFound(ConnectionName)
        Else
            If CommandTimeout > 0 AndAlso Me.ShouldProcess(ConnectionName, $"Change CommandTimeout to '{CommandTimeout}'") Then
                Engine.Logic.GetConnection(ConnectionName).CommandTimeout = CommandTimeout
            End If

            If Not String.IsNullOrEmpty(Database) AndAlso Me.ShouldProcess(ConnectionName, $"Change Database to '{Database}'") Then
                Try
                    Engine.Logic.GetConnection(ConnectionName).ChangeDatabase(Database)
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub
End Class
