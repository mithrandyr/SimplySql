Imports System.Net

Public Class ConnectionPostGre
    Inherits baseConnectionDetail
    Public Property Host As String
    Public Property Port As Integer
    Public Property Database As String
    Public Property SslMode As String = ""
    Public Property MaxAutoPrepare As Integer

    Sub New(connName As String, cmdTimeout As Integer)
        MyBase.New(connName, ProviderTypes.PostGre, cmdTimeout)
        SetAuthIntegrated()
    End Sub

    Sub SetAuthCredential(cred As NetworkCredential)
        Me.UseIntegratedSecurity = False
        Me.Credential = cred
    End Sub
    Sub SetAuthIntegrated()
        Me.UseIntegratedSecurity = True
    End Sub
End Class