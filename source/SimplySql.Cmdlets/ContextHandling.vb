Imports System.Reflection
Imports System.IO
Imports System.Runtime.InteropServices
Public Class ContextHandling
    Implements IModuleAssemblyInitializer, IModuleAssemblyCleanup

    Public Sub OnImport() Implements IModuleAssemblyInitializer.OnImport
        AddHandler AppDomain.CurrentDomain.AssemblyResolve, AddressOf HandleResolveEvent
    End Sub

    Public Sub OnRemove(psModuleInfo As PSModuleInfo) Implements IModuleAssemblyCleanup.OnRemove
        RemoveHandler AppDomain.CurrentDomain.AssemblyResolve, AddressOf HandleResolveEvent
    End Sub

    Private Shared ReadOnly BinPath As String = Path.GetFullPath(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "Bin"))
    Private Shared ReadOnly AssemblyList As IReadOnlyList(Of String) = Directory.EnumerateFiles(BinPath, "*.dll").Select(Function(file) file.Substring((BinPath.Length + 1), (file.Length - 5 - BinPath.Length))).ToList
    Private Shared IsEngineLoaded As Boolean = False

    Private Shared Function HandleResolveEvent(ByVal sender As Object, ByVal args As ResolveEventArgs) As Assembly
        Dim asmName = New AssemblyName(args.Name)
        Dim asmPath As String
        If asmName.Name.Equals("SimplySql.Engine", StringComparison.OrdinalIgnoreCase) Then
            IsEngineLoaded = True
            Return Assembly.LoadFile(Path.Combine(BinPath, "SimplySql.Engine.dll"))
        End If

        If IsEngineLoaded Then
            If asmName.Name.Equals("System.Data.SQLite", StringComparison.OrdinalIgnoreCase) Then
                If RuntimeInformation.IsOSPlatform(OSPlatform.OSX) Then
                    asmPath = Path.Combine(BinPath, $"osx-x64\{asmName.Name}.dll")
                ElseIf RuntimeInformation.IsOSPlatform(OSPlatform.Linux) Then
                    asmPath = Path.Combine(BinPath, $"linux-x64\{asmName.Name}.dll")
                Else
                    If Environment.Is64BitProcess Then
                        asmPath = Path.Combine(BinPath, $"win-x64\{asmName.Name}.dll")
                    Else
                        asmPath = Path.Combine(BinPath, $"win-x86\{asmName.Name}.dll")
                    End If
                End If
            ElseIf AssemblyList.Contains(asmName.Name) Then
                asmPath = Path.Combine(BinPath, $"{asmName.Name}.dll")
            End If
            If Not String.IsNullOrWhiteSpace(asmPath) Then Return Assembly.LoadFile(asmPath)
        End If
        Return Nothing
    End Function
End Class