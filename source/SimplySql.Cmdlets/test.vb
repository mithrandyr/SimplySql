<Cmdlet("Test", "Greeting")>
Public Class test
    Inherits PSCmdlet

    <Parameter(ValueFromPipeline:=True, Position:=0)>
    Public Property Name As String
    <Parameter()>
    Public Property ThrowError As SwitchParameter
    <Parameter()>
    Public Property ThrowErrorTerm As SwitchParameter
    <Parameter()>
    Public Property Path As String

    <Parameter(ValueFromPipeline:=True)>
    Public ObjectToHash As PSObject

    Protected Overrides Sub ProcessRecord()
        If ThrowError.IsPresent Then
            WriteError(New ErrorRecord(New Exception("throwing an error"), Nothing, Nothing, Nothing))
            'use this and then exit if you want it to processing to stop
        End If

        If ObjectToHash IsNot Nothing Then
            WriteObject(ObjectToHash.ConvertToHashtable)
            Exit Sub
        End If

        If Not String.IsNullOrWhiteSpace(Path) Then
            WriteObject($"Path: {Path}")
            WriteObject($"Processed: {Me.GetUnresolvedProviderPathFromPSPath(Path)}")
        End If
        WriteObject(Engine.Test.Greet(Name))
    End Sub

End Class

<Cmdlet("Test", "SimplySql")>
Public Class testSimplySql
    Inherits PSCmdlet

    <Parameter(Mandatory:=True, Position:=0)>
    Public Property ProviderType As Common.ProviderTypes

    Protected Overrides Sub ProcessRecord()
        Try
            WriteObject(Engine.Test.NewConnection(ProviderType))
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "InvalidProviderType", ErrorCategory.InvalidArgument, Nothing))
        End Try
    End Sub

End Class

