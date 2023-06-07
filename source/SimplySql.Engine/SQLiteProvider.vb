Imports System.Collections.Specialized
Imports System.Data.SQLite

Public Class SQLiteProvider
    Inherits ProviderBase

    Public Sub New(connectionName As String, commandTimeout As Integer, connection As SQLiteConnection)
        MyBase.New(connectionName, ProviderTypes.SQLite, connection, commandTimeout)
    End Sub

    Public Overloads ReadOnly Property Connection As SQLiteConnection
        Get
            Return DirectCast(MyBase.Connection, SQLiteConnection)
        End Get
    End Property

    Public Overrides Function ConnectionInfo() As OrderedDictionary
        Dim od = MyBase.ConnectionInfo
        od.Add("ServerVersion", Connection.ServerVersion)
        od.Add("DataSource", Connection.DataSource)
        Return od
    End Function

    Public Overrides Function GetDataSet(query As String, cmdTimeout As Integer, params As Hashtable, useProviderTypes As Boolean) As Data.DataSet
        If Not useProviderTypes Then
            Return MyBase.GetDataset(query, cmdTimeout, params, False)
        Else
            Using cmd As SQLiteCommand = GetCommand(query, cmdTimeout, params)
                Using da As New SQLiteDataAdapter(cmd)
                    Dim ds As New Data.DataSet
                    da.ReturnProviderSpecificTypes = True
                    Try
                        da.Fill(ds)
                        Return ds
                    Catch ex As Exception
                        ex.Data.Add("Query", query)
                        ex.Data.Add("Parameters", params)
                        Throw ex
                    End Try
                End Using
            End Using
        End If
    End Function

#Region "Not Supported"
    Public Overrides Sub ChangeDatabase(databaseName As String)
        Throw New NotSupportedException($"SQLite does not support databases, cannot change to {databaseName}.")
    End Sub

    Public Overrides Function GetMessage() As SqlMessage
        Throw New NotSupportedException("SQLiteProvider does not support SqlMessages.")
    End Function

    Public Overrides Sub ClearMessages()
        Throw New NotSupportedException("SQLiteProvider does not support SqlMessages.")
    End Sub
    Public Overrides ReadOnly Property HasMessages As Boolean
        Get
            Throw New NotSupportedException("SQLiteProvider does not support SqlMessages.")
        End Get
    End Property
#End Region

#Region "Shared Functions"
    Public Shared Function Create(connectionName As String, dataSource As String, password As String, commandTimeout As Integer, Optional additionalParams As Hashtable = Nothing) As SQLiteProvider
        Dim sb As New SQLiteConnectionStringBuilder
        If Not dataSource.Equals(":memory:", StringComparison.OrdinalIgnoreCase) Then
            Dim filepath = New IO.FileInfo(dataSource)
            If Not filepath.Directory.Exists Then filepath.Directory.Create()
        End If

        sb.DataSource = dataSource

        If Not String.IsNullOrWhiteSpace(password) Then sb.Password = password

        'Process additional parameters through the hashtable
        If additionalParams IsNot Nothing Then
            For Each key In additionalParams.Keys
                sb.Add(key, additionalParams(key))
            Next
        End If

        Return Create(connectionName, sb.ToString, commandTimeout)
    End Function
    Public Shared Function Create(connectionName As String, connectionString As String, commandTimeout As Integer) As SQLiteProvider
        Dim conn As New SQLiteConnection(connectionString)
        Return New SQLiteProvider(connectionName, commandTimeout, conn)
    End Function
#End Region
End Class
