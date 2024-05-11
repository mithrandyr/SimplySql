Imports System.Reflection
Imports System.IO
Imports System.Runtime.InteropServices
Public Class ContextHandling
    Implements IModuleAssemblyInitializer, IModuleAssemblyCleanup

    Shared Sub New()
        AppPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
        BinPath = Path.Combine(AppPath, "bin")
        AssemblyList = Directory.EnumerateFiles(BinPath, "*.dll").Select(Function(file) IO.Path.GetFileNameWithoutExtension(file).ToLower).ToList
        PlatformAssemblyList = Directory.GetDirectories(BinPath).SelectMany(Function(dir) Directory.EnumerateFiles(dir)).Select(Function(file) IO.Path.GetFileNameWithoutExtension(file).ToLower).Distinct.ToList
    End Sub

    Public Sub OnImport() Implements IModuleAssemblyInitializer.OnImport
        AddHandler AppDomain.CurrentDomain.AssemblyResolve, AddressOf HandleResolveEvent
    End Sub

    Public Sub OnRemove(psModuleInfo As PSModuleInfo) Implements IModuleAssemblyCleanup.OnRemove
        RemoveHandler AppDomain.CurrentDomain.AssemblyResolve, AddressOf HandleResolveEvent
    End Sub

    Private Shared ReadOnly AppPath As String
    Private Shared ReadOnly BinPath As String
    Private Shared ReadOnly AssemblyList As IReadOnlyList(Of String)
    Private Shared ReadOnly PlatformAssemblyList As IReadOnlyList(Of String)
    Private Shared IsEngineLoaded As Boolean = False

    Private Shared Function HandleResolveEvent(ByVal sender As Object, ByVal args As ResolveEventArgs) As Assembly
        Dim asmName = New AssemblyName(args.Name)
        Dim asmPath As String = String.Empty

#If DEBUG Then
        Console.WriteLine($"{Environment.NewLine}ASSEMBLY LOAD: '{asmName}' BECAUSE '{args.RequestingAssembly}'{Environment.NewLine}")
#End If

        If asmName.Name.Equals("SimplySql.Engine", StringComparison.OrdinalIgnoreCase) Then
            IsEngineLoaded = True
            Return Assembly.LoadFile(Path.Combine(BinPath, "SimplySql.Engine.dll"))
        End If

        If IsEngineLoaded Then
            If AssemblyList.Contains(asmName.Name.ToLower) Then
                asmPath = Path.Combine(BinPath, $"{asmName.Name}.dll")
            ElseIf PlatformAssemblyList.Contains(asmName.Name.ToLower) Then
                If RuntimeInformation.IsOSPlatform(OSPlatform.OSX) Then
                    asmPath = Path.Combine(BinPath, "osx-x64", $"{asmName.Name}.dll")
                ElseIf RuntimeInformation.IsOSPlatform(OSPlatform.Linux) Then
                    asmPath = Path.Combine(BinPath, "linux-x64", $"{asmName.Name}.dll")
                Else
                    If Environment.Is64BitProcess Then
                        asmPath = Path.Combine(BinPath, $"win-x64\{asmName.Name}.dll")
                    Else
                        asmPath = Path.Combine(BinPath, $"win-x86\{asmName.Name}.dll")
                    End If
                End If
            End If
            If Not String.IsNullOrWhiteSpace(asmPath) Then
                Return Assembly.LoadFile(asmPath)
            End If
        End If

        Return Nothing
    End Function
End Class