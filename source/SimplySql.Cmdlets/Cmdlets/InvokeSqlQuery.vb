<Cmdlet(VerbsLifecycle.Invoke, "SqlQuery", SupportsShouldProcess:=True, DefaultParameterSetName:="hashtable")>
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

    Public Property CommandTimeout As Integer = -1

    <Parameter(Mandatory:=True, ParameterSetName:="object", Position:=1, ValueFromPipeline:=True)>
    Public Property ParamObject As PSObject
    <Parameter()>
    Public Property Stream As SwitchParameter
    <Parameter()>
    Public Property AsDataTable As SwitchParameter
    <Parameter()>
    <[Alias]("ProviderTypes")>
    Public Property UseTypesFromProvider As SwitchParameter
#End Region
    Protected Overrides Sub ProcessRecord()
        If Not Engine.Logic.ConnectionExists(ConnectionName) Then
            WriteError(ConnectionNotFoundError(ConnectionName))
        Else
            Dim singleQuery As String = String.Join(Environment.NewLine, Query)

            If Me.ShouldProcess(ConnectionName, $"Execute '{singleQuery}'") Then
                If ParameterSetName.Equals("object", StringComparison.OrdinalIgnoreCase) Then Parameters = ParamObject.ConvertToHashtable
                Try
                    If Stream.IsPresent Then
                        'TODO need to implement
                        Throw New NotImplementedException("-Stream is not implemented")
                    Else
                        Using ds = Engine.Logic.GetConnection(ConnectionName).GetDataSet(singleQuery, CommandTimeout, Parameters, UseTypesFromProvider.IsPresent)
                            If ds.Tables.Count = 0 Then
                                WriteWarning("Query returned no resultset.  This occurs when the query has no select statement or invokes a stored procedure that does not return a resultset.  Use 'Invoke-SqlUpdate' to avoid this warning.")
                            ElseIf ds.Tables.Count > 1 OrElse AsDataTable.IsPresent Then
                                WriteObject(ds.Tables)
                            Else
                                WriteObject(ds.Tables(0).Rows)
                            End If
                        End Using
                    End If
                    WriteVerbose($"Retrieved Results from '{ConnectionName}'.")
                Catch ex As Exception
                    WriteError(New ErrorRecord(ex, MyInvocation.MyCommand.Name, ErrorCategory.InvalidOperation, ConnectionName))
                End Try
            End If
        End If
    End Sub

End Class
