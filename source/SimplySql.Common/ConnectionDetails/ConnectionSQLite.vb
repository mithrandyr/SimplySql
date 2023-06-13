Public Class ConnectionSQLite
    Inherits baseConnectionDetail
    Public ReadOnly Property Database As String

    Sub New(connName As String, db As String)
        MyBase.New(connName)
        Me.Database = db

    End Sub
    Sub New(connName As String, db As String, pass As String)
        MyBase.New(connName, New Net.NetworkCredential(Nothing, pass))
        Me.Database = db
    End Sub
End Class
