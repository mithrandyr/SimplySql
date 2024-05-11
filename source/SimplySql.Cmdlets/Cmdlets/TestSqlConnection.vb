<Cmdlet(VerbsDiagnostic.Test, "SqlConnection", DefaultParameterSetName:="single")>
<[Alias]("tsc")>
Public Class TestSqlConnection
    Inherits PSCmdlet

#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True, ValueFromPipeline:=True, ParameterSetName:="single", Position:=0)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    <PSDefaultValue(Value:="default")>
    Public Property ConnectionName As String = "default"

    <Parameter(Mandatory:=True, ParameterSetName:="all")>
    Public Property All As SwitchParameter

    <Parameter(ParameterSetName:="single")>
    Public Property Detailed As SwitchParameter
#End Region

    Protected Overrides Sub EndProcessing()
        If All.IsPresent Then
            WriteObject(Engine.Logic.Connections.Count > 0)
        Else
            If Detailed Then
                WriteObject(Engine.Logic.ConnectionExists(ConnectionName))
            Else
                WriteObject(Engine.Logic.ConnectionExists(ConnectionName, False) = Engine.ValidateConnectionResult.Found)
            End If
        End If
    End Sub
End Class
