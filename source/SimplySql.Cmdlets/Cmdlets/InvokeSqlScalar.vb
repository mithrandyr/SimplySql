<Cmdlet(VerbsLifecycle.Invoke, "SqlScalar", SupportsShouldProcess:=True, DefaultParameterSetName:="object")>
<[Alias]("iss")>
Public Class InvokeSqlScalar
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
#End Region

    Protected Overrides Sub ProcessRecord()
        If ValidateConnection(ConnectionName) Then
            Dim singleQuery As String = String.Join(Environment.NewLine, Query)

            If Me.ShouldProcess(ConnectionName, $"Execute '{singleQuery}'") Then
                If ParameterSetName.Equals("object", StringComparison.OrdinalIgnoreCase) AndAlso ParamObject IsNot Nothing Then
                    Parameters = ParamObject.ConvertToHashtable
                End If
                Try
                    WriteObject(Engine.Logic.GetConnection(ConnectionName).GetScalar(singleQuery, CommandTimeout, Parameters))
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub

End Class
