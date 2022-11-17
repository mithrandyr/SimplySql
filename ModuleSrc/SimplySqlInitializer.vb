Public Class SimplySqlInitializer
    Implements IModuleAssemblyInitializer, IModuleAssemblyCleanup

    Private ReadOnly Property IsFramework As Boolean
    Public Sub New()
        'use the below when we have a separate process for Core versus Framework
        'IsFramework = Runtime.InteropServices.RuntimeInformation.FrameworkDescription.StartsWith(".NET Framework", StringComparison.OrdinalIgnoreCase)
        IsFramework = True
    End Sub

    Public Sub OnImport() Implements IModuleAssemblyInitializer.OnImport
        Console.WriteLine("Processing providers...")
        Console.WriteLine(String.Format("From: {0}", DependencyResolution.LoadPath))

        Dim ProviderAssembly() As String = New String() {"System.Data.SqlClient.dll"}
        For Each pa In ProviderAssembly
            Dim path = IO.Path.Combine(DependencyResolution.LoadPath, pa)
            Console.WriteLine(String.Format("Loading: {0}", path))
            'Reflection.Assembly.LoadFrom(path)
        Next

        If IsFramework Then
            AddHandler AppDomain.CurrentDomain.AssemblyResolve, AddressOf DependencyResolution.Resolve
        End If
    End Sub

    Public Sub OnRemove(psModuleInfo As PSModuleInfo) Implements IModuleAssemblyCleanup.OnRemove
        If IsFramework Then
            RemoveHandler AppDomain.CurrentDomain.AssemblyResolve, AddressOf DependencyResolution.Resolve
        End If
    End Sub
End Class

NotInheritable Class DependencyResolution
    Private Sub New()
    End Sub
    Public Shared Function Resolve(sender As Object, e As ResolveEventArgs) As Reflection.Assembly

        Debug.WriteLine(e.Name)
        Return Nothing
    End Function

    Public Shared ReadOnly Property LoadPath As String = IO.Path.GetDirectoryName(Reflection.Assembly.GetExecutingAssembly().Location)

End Class
