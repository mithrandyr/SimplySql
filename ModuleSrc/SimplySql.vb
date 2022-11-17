Imports LoadFileModule.Engine

Namespace LoadFileModule.Cmdlets
    <Cmdlet(VerbsDiagnostic.Test, "LoadFile")>
    Public Class TestLoadFileCommand
        Inherits Cmdlet

        <Parameter(Mandatory:=True)>
        Public Property Path As String

        Protected Overrides Sub EndProcessing()
            New Runner().Use(Path)
        End Sub
    End Class

    Public Class ModuleContextHandler
        Inherits IModuleAssemblyInitializer
        Implements IModuleAssemblyCleanup

        Private Shared s_dependencies As IReadOnlyDictionary(Of String, Integer) = New Dictionary(Of String, Integer) From {
            {"CsvHelper", 15}
        }
        Private Shared s_dependenciesDirPath As String = Path.GetFullPath(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "Dependencies"))
        Private Shared s_engineLoaded As Boolean = False

        Public Sub OnImport()
            AppDomain.CurrentDomain.AssemblyResolve += AddressOf HandleResolveEvent
        End Sub

        Public Sub OnRemove(ByVal psModuleInfo As PSModuleInfo)
            AppDomain.CurrentDomain.AssemblyResolve -= AddressOf HandleResolveEvent
        End Sub

        Private Shared Function HandleResolveEvent(ByVal sender As Object, ByVal args As ResolveEventArgs) As Assembly
            Dim asmName = New AssemblyName(args.Name)

            If asmName.Name.Equals("LoadFileModule.Engine") Then
                s_engineLoaded = True
                Return Assembly.LoadFile(Path.Combine(s_dependenciesDirPath, "Unrelated.Engine.dll"))
            End If

            Dim requiredMajorVersion As Integer = Nothing

            If s_engineLoaded AndAlso s_dependencies.TryGetValue(asmName.Name, requiredMajorVersion) AndAlso asmName.Version.Major = requiredMajorVersion Then
                Dim asmPath As String = Path.Combine(s_dependenciesDirPath, $"{asmName.Name}.dll")
                Return Assembly.LoadFile(asmPath)
            End If

            Return Nothing
        End Function
    End Class
End Namespace


Public Class SimplySqlInitializer
    Implements IModuleAssemblyInitializer

    'Private ReadOnly Property IsFramework As Boolean
    Public Sub New()
        'use the below when we have a separate process for Core versus Framework
        'IsFramework = Runtime.InteropServices.RuntimeInformation.FrameworkDescription.StartsWith(".NET Framework", StringComparison.OrdinalIgnoreCase)
        'IsFramework = True
    End Sub

    Public Sub OnImport() Implements IModuleAssemblyInitializer.OnImport
        Console.WriteLine("Processing providers...")
        Dim basePath As String = IO.Path.GetDirectoryName(Reflection.Assembly.GetExecutingAssembly().Location)
        Console.WriteLine(String.Format("From: {0}", basePath))

        Dim ProviderAssembly() As String = New String() {} '{"System.Data.SqlClient.dll"}
        For Each pa In ProviderAssembly
            Dim path = IO.Path.Combine(basePath, pa)
            Console.WriteLine(String.Format("Loading: {0}", path))
            'Reflection.Assembly.LoadFrom(path)
        Next

        AddHandler AppDomain.CurrentDomain.AssemblyResolve, AddressOf DependencyResolution.Resolve
    End Sub


End Class

Public Class SimplySqlCleanup
    Implements IModuleAssemblyCleanup
    Public Sub OnRemove(psModuleInfo As PSModuleInfo) Implements IModuleAssemblyCleanup.OnRemove
        RemoveHandler AppDomain.CurrentDomain.AssemblyResolve, AddressOf DependencyResolution.Resolve
    End Sub
End Class

Public NotInheritable Class DependencyResolution
    Private Sub New()
    End Sub

    Public Shared ReadOnly Property Assemblies As New List(Of String)
    Public Shared Function Resolve(sender As Object, e As ResolveEventArgs) As Reflection.Assembly
        Assemblies.Add(e.Name)
        Console.WriteLine(String.Format("Resolving: {0}"), e.Name)
        Return Nothing
    End Function
End Class
