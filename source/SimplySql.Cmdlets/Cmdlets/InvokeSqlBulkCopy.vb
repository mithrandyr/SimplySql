<Cmdlet(VerbsLifecycle.Invoke, "SqlBulkCopy", SupportsShouldProcess:=True, DefaultParameterSetName:="hashtable")>
Public Class InvokeSqlBulkCopy
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <ValidateNotNullOrEmpty()> <[Alias]("SrcCN")> <PSDefaultValue(Value:="default")>
    Public Property SourceConnectionName As String = "default"

    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <ValidateNotNullOrEmpty()> <[Alias]("DstCN")> <PSDefaultValue(Value:="default")>
    Public Property DestinationConnectionName As String = "default"

    <Parameter(ParameterSetName:="table", ValueFromPipelineByPropertyName:=True)>
    <Parameter(ParameterSetName:="query", Mandatory:=True, ValueFromPipelineByPropertyName:=True)>
    <ValidateNotNullOrEmpty()>
    Public Property DestinationTable As String

    <Parameter(ParameterSetName:="table", Mandatory:=True, ValueFromPipelineByPropertyName:=True)>
    <ValidateNotNullOrEmpty()>
    Public Property SourceTable As String

    <Parameter(ParameterSetName:="query", Mandatory:=True, ValueFromPipelineByPropertyName:=True)>
    <ValidateNotNullOrEmpty()>
    Public Property SourceQuery As String()

    <Parameter(ParameterSetName:="query", ValueFromPipelineByPropertyName:=True)>
    Public Property SourceParameters As Hashtable

    <Parameter()>
    Public Property ColumnMap As Hashtable

    <Parameter()>
    <ValidateRange(1, 50000)> <PSDefaultValue(Value:=500)>
    Public Property BatchSize As Integer = 500

    <Parameter()>
    <PSDefaultValue(Value:="-1 (No Timeout)>")>
    Public Property BatchTimeout As Integer = -1

    <Parameter()>
    Public Property Notify As SwitchParameter
#End Region

    Protected Overrides Sub EndProcessing()
        If SourceConnectionName.Equals(DestinationConnectionName, StringComparison.OrdinalIgnoreCase) Then
            Dim ex As New ArgumentException($"You cannot use the same connection for both the source and destination ({SourceConnectionName}).", NameOf(DestinationConnectionName))
            WriteError(New ErrorRecord(ex, MyInvocation.MyCommand.Name, ErrorCategory.InvalidArgument, DestinationConnectionName))
        Else
            If ValidateConnection(SourceConnectionName) And ValidateConnection(DestinationConnectionName) Then
                If Me.ShouldProcess(DestinationConnectionName, $"Execute bulkloading into '{DestinationTable}'") Then
                    Dim singleQuery As String

                    If ParameterSetName = "table" Then
                        Dim queryColumns As String = "*"
                        If ColumnMap IsNot Nothing Then queryColumns = String.Join(", ", ColumnMap.Keys)
                        singleQuery = $"SELECT {queryColumns} FROM {SourceTable}"

                        If String.IsNullOrWhiteSpace(DestinationTable) Then DestinationTable = SourceTable
                    Else
                        singleQuery = String.Join(Environment.NewLine, SourceQuery)
                    End If

                    Try
                        Dim srcReader = Engine.GetConnection(SourceConnectionName).GetDataReader(singleQuery, SourceParameters)
                        Dim notifyAction As Action(Of Long) = Nothing
                        If Notify Then notifyAction = Sub(x) WriteProgress(New ProgressRecord(0, "SimplySql BulkCopy", DestinationTable) With {.CurrentOperation = $"Insert {x} rows."})
                        WriteObject(Engine.GetConnection(DestinationConnectionName).BulkLoad(srcReader, DestinationTable, ColumnMap, BatchSize, BatchTimeout, notifyAction))
                    Catch ex As Exception
                        ErrorOperationFailed(ex, DestinationConnectionName)
                    Finally
                        If Notify Then WriteProgress(New ProgressRecord(0, "SimplySql BulkCopy", DestinationTable) With {.RecordType = ProgressRecordType.Completed})
                    End Try
                End If
            End If
        End If
    End Sub

End Class
