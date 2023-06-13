Public Class ConnectionPostGre
    Inherits baseConnectionDetail
    Public Property RequireSSL As Boolean = False
    Public Property TrustServerCertificate As Boolean = False
    Public ReadOnly Property UseIntegratedSecurity As Boolean = False
    Sub New()
        MyBase.New(Nothing, Nothing)
        UseIntegratedSecurity = True
    End Sub
End Class