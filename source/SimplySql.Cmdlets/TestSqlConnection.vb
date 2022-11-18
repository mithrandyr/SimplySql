<Cmdlet(VerbsDiagnostic.Test, "SqlConnection", DefaultParameterSetName:="single")>
Public Class TestSqlConnection
    Inherits PSCmdletWithConnectionName

#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True, ParameterSetName:="single", Position:=0)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"

    <Parameter(Mandatory:=True, ParameterSetName:="all")>
    Public Property All As SwitchParameter
#End Region

    Protected Overrides Sub EndProcessing()
        If All.IsPresent Then
            WriteObject(Engine.Logic.Connections.Count > 0)
        Else
            WriteObject(Engine.Logic.Connections.ContainsKey(ConnectionName))
        End If
    End Sub
End Class
