<Cmdlet("Test", "Greeting")>
Public Class test
    Inherits PSCmdlet

    <Parameter(ValueFromPipeline:=True, Position:=0)>
    Public Property Name As String

    Protected Overrides Sub ProcessRecord()
        WriteObject(Engine.Test.Greet(Name))
    End Sub

End Class

<Cmdlet("Test", "SimplySql")>
Public Class testSimplySql
    Inherits PSCmdlet

    <Parameter(Mandatory:=True, Position:=0)>
    Public Property ProviderType As Common.ProviderType

    Protected Overrides Sub ProcessRecord()
        Try
            WriteObject(Engine.Test.NewConnection(ProviderType))
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "InvalidProviderType", ErrorCategory.InvalidArgument, Nothing))
        End Try
    End Sub

End Class

