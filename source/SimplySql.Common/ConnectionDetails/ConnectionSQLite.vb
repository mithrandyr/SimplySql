Public Class ConnectionSQLite
    Inherits baseConnectionDetail
    Public Property Database As String

    Sub New(connName As String, cmdTimeout As Integer)
        MyBase.New(connName, ProviderTypes.SQLite, cmdTimeout)
        Me.UseIntegratedSecurity = False
    End Sub
End Class
