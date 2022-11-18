<Cmdlet(VerbsCommon.[New], "SQLiteConnection", DefaultParameterSetName:="default")>
Public Class NewSQLiteConnection
    Inherits PSCmdlet

#Region "Cmdlet Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"

    <Parameter(ValueFromPipelineByPropertyName:=True)>
    Public Property CommandTimeout As Integer = 30

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=0)>
    <[Alias]("FilePath")>
    Public Property DataSource As String = ":memory:"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=1)>
    Public Property Password As String

    <Parameter(ParameterSetName:="conn", ValueFromPipelineByPropertyName:=True)>
    Public Property ConnectionString As String
#End Region

    Protected Overrides Sub ProcessRecord()


    End Sub
End Class
