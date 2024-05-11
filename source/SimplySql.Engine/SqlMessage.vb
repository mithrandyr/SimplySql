Public Class SqlMessage
    Public ReadOnly Property Received As DateTime
    Public ReadOnly Property Message As String

    Public Sub New(_message As String, Optional _received As DateTime? = Nothing)
        If _received Is Nothing Then _received = DateTime.Now
        Received = _received
        Message = _message
    End Sub
End Class
