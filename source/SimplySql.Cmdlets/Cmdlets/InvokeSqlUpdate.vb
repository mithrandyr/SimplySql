Imports System.Data

<Cmdlet(VerbsLifecycle.Invoke, "SqlUpdate", SupportsShouldProcess:=True, DefaultParameterSetName:="object")>
<[Alias]("isu")>
Public Class InvokeSqlUpdate
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    <PSDefaultValue(Value:="default")>
    Public Property ConnectionName As String = "default"

    <Parameter(Mandatory:=True, Position:=0)>
    <ValidateNotNullOrEmpty>
    Public Property Query As String()

    <Parameter(Mandatory:=True, ParameterSetName:="hashtable", Position:=1)>
    Public Property Parameters As Hashtable

    <Parameter()>
    <PSDefaultValue(Value:="-1 (No Timeout)>")>
    Public Property CommandTimeout As Integer = -1

    <Parameter(ParameterSetName:="object", Position:=1, ValueFromPipeline:=True)>
    Public Property ParamObject As PSObject

    <Parameter(Mandatory:=True, ParameterSetName:="cmd")>
    Public Property Command As IDbCommand

#End Region

    Protected Overrides Sub ProcessRecord()
        If ValidateConnection(ConnectionName) Then
            Dim conn = Engine.Logic.GetConnection(ConnectionName)
            If ParameterSetName = "cmd" AndAlso Me.ShouldProcess(ConnectionName, $"Execute '{Command.CommandText}'") Then
                Try
                    WriteObject(conn.Update(Command))
                    WriteVerbose($"Executed command on '{ConnectionName}'.")
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            Else
                Dim singleQuery As String = String.Join(Environment.NewLine, Query)
                If ParameterSetName.Equals("object", StringComparison.OrdinalIgnoreCase) AndAlso ParamObject IsNot Nothing Then
                    Parameters = ParamObject.ConvertToHashtable
                End If

                If Me.ShouldProcess(ConnectionName, $"Execute '{singleQuery}'") Then
                    Try
                        WriteObject(conn.Update(singleQuery, CommandTimeout, Parameters))
                        WriteVerbose($"Executed query on '{ConnectionName}'.")
                    Catch ex As Exception
                        ErrorOperationFailed(ex, ConnectionName)
                    End Try
                End If
            End If
        End If
    End Sub

End Class
