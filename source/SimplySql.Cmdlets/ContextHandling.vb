Imports System.Reflection
Imports System.IO
Imports System.Runtime.InteropServices
Public Class ContextHandling
    Implements IModuleAssemblyInitializer, IModuleAssemblyCleanup

    Shared Sub New()
        AppPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
        BinPath = Path.Combine(AppPath, "bin")
        AssemblyList = Directory.EnumerateFiles(BinPath, "*.dll").Select(Function(file) IO.Path.GetFileNameWithoutExtension(file).ToLower).ToList
        FrameworkList = Directory.EnumerateFiles(Path.Combine(BinPath, "PS5"), "*.dll").Select(Function(file) IO.Path.GetFileNameWithoutExtension(file).ToLower).ToList
        CoreList = Directory.EnumerateFiles(Path.Combine(BinPath, "PS7"), "*.dll").Select(Function(file) IO.Path.GetFileNameWithoutExtension(file).ToLower).ToList
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
    Private Shared ReadOnly FrameworkList As IReadOnlyList(Of String)
    Private Shared ReadOnly CoreList As IReadOnlyList(Of String)
    Private Shared ReadOnly PlatformAssemblyList As IReadOnlyList(Of String)
    Private Shared IsEngineLoaded As Boolean = False

    Private Shared Function HandleResolveEvent(ByVal sender As Object, ByVal args As ResolveEventArgs) As Assembly
        Dim asmName = New AssemblyName(args.Name)

#If DEBUG Then
        Console.WriteLine($"{Environment.NewLine}ASSEMBLY LOAD: '{asmName}' BECAUSE '{args.RequestingAssembly}'{Environment.NewLine}")
#End If

        If asmName.Name.Equals("SimplySql.Engine", StringComparison.OrdinalIgnoreCase) Then
            Dim asmPath = FindFile(asmName.Name)
            If asmPath IsNot Nothing Then
                IsEngineLoaded = True
                Return Assembly.LoadFile(asmPath)
            Else
                Throw New FileLoadException("Cannot find 'SimplySql.Engine'", asmPath)
            End If
        End If

        If IsEngineLoaded Then
            Dim asmPath = FindFile(asmName.Name)
            If asmPath IsNot Nothing Then Return Assembly.LoadFile(asmPath)
        End If

        Return Nothing
    End Function

    Private Shared Function FindFile(asmName As String) As String
        If AssemblyList.Contains(asmName.ToLower) Then
            Return Path.Combine(BinPath, $"{asmName}.dll")
        Else
            If Environment.Version.Major = 4 Then 'PS 5.1
                If FrameworkList.Contains(asmName.ToLower) Then
                    Return Path.Combine(BinPath, "PS5", $"{asmName}.dll")
                Else
                    If Environment.Is64BitProcess Then
                        Dim filePath = Path.Combine(BinPath, "PS5", "win-x64", $"{asmName}.dll")
                        If IO.File.Exists(filePath) Then Return filePath
                    Else
                        Dim filePath = Path.Combine(BinPath, "PS5", "win-x86", $"{asmName}.dll")
                        If IO.File.Exists(filePath) Then Return filePath
                    End If
                End If
            Else 'PS 6+
                If CoreList.Contains(asmName.ToLower) Then
                    Return Path.Combine(BinPath, "PS7", $"{asmName}.dll")
                Else
                    If RuntimeInformation.IsOSPlatform(OSPlatform.Linux) Then
                        Dim filePath = Path.Combine(BinPath, "PS7", "linux-x64", $"{asmName}.dll")
                        If IO.File.Exists(filePath) Then Return filePath
                    ElseIf RuntimeInformation.IsOSPlatform(OSPlatform.OSX) Then
                        Dim filePath = Path.Combine(BinPath, "PS7", "osx-x64", $"{asmName}.dll")
                        If IO.File.Exists(filePath) Then Return filePath
                    Else
                        Dim filePath = Path.Combine(BinPath, "PS7", "win-x64", $"{asmName}.dll")
                        If IO.File.Exists(filePath) Then Return filePath
                    End If
                End If
            End If
        End If
        Return Nothing
    End Function
End Class