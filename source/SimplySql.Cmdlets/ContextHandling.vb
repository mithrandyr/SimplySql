Imports System.Reflection
Imports System.IO
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

        If asmName.Name.Equals("SimplySql.Engine") Then
            IsEngineLoaded = True
            Return Assembly.LoadFile(Path.Combine(BinPath, "SimplySql.Engine.dll"))
        End If

        If IsEngineLoaded AndAlso AssemblyList.Contains(asmName.Name) Then
            Dim asmPath As String = Path.Combine(BinPath, $"{asmName.Name}.dll")
            Return Assembly.LoadFile(asmPath)
        End If

        Return Nothing
    End Function
End Class