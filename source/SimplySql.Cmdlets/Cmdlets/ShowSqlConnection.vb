<Cmdlet(VerbsCommon.Show, "SqlConnection", DefaultParameterSetName:="single")>
<[Alias]("ssc")>
Public Class ShowSqlConnection
    Inherits PSCmdlet

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
            WriteObject(Engine.Logic.Connections, True)
        Else
            WriteObject(Engine.Logic.ConnectionExists(ConnectionName))
        End If
    End Sub
End Class
