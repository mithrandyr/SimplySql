<Cmdlet(VerbsCommon.Show, "SqlConnection", DefaultParameterSetName:="single")>
<[Alias]("ssc")>
Public Class ShowSqlConnection
    Inherits PSCmdlet

#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True, ValueFromPipeline:=True, ParameterSetName:="single", Position:=0)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    <PSDefaultValue(Value:="default")>
    Public Property ConnectionName As String = "default"

    <Parameter(Mandatory:=True, ParameterSetName:="all")>
    Public Property All As SwitchParameter
#End Region

    Protected Overrides Sub EndProcessing()
        If All.IsPresent Then
            WriteObject(Engine.Logic.Connections.Keys, True)
        Else
            If Engine.Logic.ConnectionExists(ConnectionName, False) = Engine.ValidateConnectionResult.Found Then
                Dim connInfo As New PSObject()
                For Each de As DictionaryEntry In Engine.Logic.GetConnection(ConnectionName).ConnectionInfo
                    connInfo.Properties.Add(New PSNoteProperty(de.Key, de.Value))
                Next
                WriteObject(connInfo)
            End If
        End If
    End Sub
End Class
