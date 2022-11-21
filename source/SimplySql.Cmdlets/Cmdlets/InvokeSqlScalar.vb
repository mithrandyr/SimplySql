<Cmdlet(VerbsLifecycle.Invoke, "SqlScalar", SupportsShouldProcess:=True, DefaultParameterSetName:="hashtable")>
Public Class InvokeSqlScalar
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
#End Region

    Protected Overrides Sub ProcessRecord()
        If Not Engine.Logic.ConnectionExists(ConnectionName) Then
            WriteError(ConnectionNotFoundError(ConnectionName))
        Else
            Dim singleQuery As String = String.Join(Environment.NewLine, Query)

            If Me.ShouldProcess(ConnectionName, $"Execute '{singleQuery}'") Then
                If ParameterSetName.Equals("object", StringComparison.OrdinalIgnoreCase) Then Parameters = ParamObject.ConvertToHashtable
                Try
                    WriteObject(Engine.Logic.GetConnection(ConnectionName).GetScalar(singleQuery, CommandTimeout, Parameters))
                    WriteVerbose($"Retrieved Scalar from '{ConnectionName}'.")
                Catch ex As Exception
                    WriteError(New ErrorRecord(ex, MyInvocation.MyCommand.Name, ErrorCategory.InvalidOperation, ConnectionName))
                End Try
            End If
        End If
    End Sub

End Class
