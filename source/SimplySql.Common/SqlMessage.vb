Public Class SqlMessage
    Public ReadOnly Property Received As DateTime
    Public ReadOnly Property Message As String

    Public Sub New(_received As DateTime, _message As String)
        Received = _received
        Message = _message
    End Sub
End Class
