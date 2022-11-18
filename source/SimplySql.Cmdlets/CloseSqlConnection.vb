<CmdletBinding()>
<Cmdlet("Close", "SqlConnection")>
Public Class CloseSqlConnection
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"
#End Region

    Protected Overrides Sub ProcessRecord()

        If Me.shou Then

    End Sub

End Class
