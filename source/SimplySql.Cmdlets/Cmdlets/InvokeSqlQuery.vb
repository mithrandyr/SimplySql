<Cmdlet(VerbsLifecycle.Invoke, "SqlQuery", SupportsShouldProcess:=True, DefaultParameterSetName:="hashtable")>
<[Alias]("isq")>
Public Class InvokeSqlQuery
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"

    <Parameter(Mandatory:=True, Position:=0)>
    <ValidateNotNullOrEmpty>
    Public Property Query As String()

    <Parameter(ParameterSetName:="hashtable", Position:=1)>
    Public Property Parameters As Hashtable

    <Parameter()>
    Public Property CommandTimeout As Integer = -1

    <Parameter(Mandatory:=True, ParameterSetName:="object", Position:=1, ValueFromPipeline:=True)>
    Public Property ParamObject As PSObject

    <Parameter(ParameterSetName:="hashtable")>
    <Parameter(ParameterSetName:="object")>
    Public Property Stream As SwitchParameter

    <Parameter()>
    Public Property AsDataTable As SwitchParameter

    <Parameter()>
    <[Alias]("ProviderTypes")>
    Public Property UseTypesFromProvider As SwitchParameter
#End Region
    Protected Overrides Sub ProcessRecord()
        If ValidateConnection(ConnectionName) Then
            Dim singleQuery As String = String.Join(Environment.NewLine, Query)

            If Me.ShouldProcess(ConnectionName, $"Execute '{singleQuery}'") Then
                If ParameterSetName.Equals("object", StringComparison.OrdinalIgnoreCase) Then Parameters = ParamObject.ConvertToHashtable
                Try
                    If Stream.IsPresent Then
                        Using dr = Engine.Logic.GetConnection(ConnectionName).GetDataReader(singleQuery, Parameters, CommandTimeout)
                            WriteObject(dr.ConvertToPSObject, True)
                        End Using
                    Else
                        Using ds = Engine.Logic.GetConnection(ConnectionName).GetDataSet(singleQuery, CommandTimeout, Parameters, UseTypesFromProvider.IsPresent)
                            If ds.Tables.Count = 0 Then
                                WriteWarning("Query returned no resultset.  This occurs when the query has no select statement or invokes a stored procedure that does not return a resultset.  Use 'Invoke-SqlUpdate' to avoid this warning.")
                            ElseIf ds.Tables.Count > 1 OrElse AsDataTable.IsPresent Then
                                WriteObject(ds.Tables, True)
                            Else
                                WriteObject(ds.Tables(0).Rows, True)
                            End If
                        End Using
                    End If
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub

End Class
