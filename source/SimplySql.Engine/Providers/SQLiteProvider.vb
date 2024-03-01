Imports System.Collections.Specialized
Imports System.Data.SQLite

Public Class SQLiteProvider
    Inherits ProviderBase
    Public Overloads ReadOnly Property Connection As SQLiteConnection
        Get
            Return DirectCast(MyBase.Connection, SQLiteConnection)
        End Get
    End Property

    Private Sub New(connectionName As String, commandTimeout As Integer, connection As SQLiteConnection)
        MyBase.New(connectionName, ProviderTypes.SQLite, connection, commandTimeout)
    End Sub

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
                        ex.AddQueryDetails(query, params)
                        Throw
                    End Try
                End Using
            End Using
        End If
    End Function

#Region "Not Supported"
    Public Overrides Sub ChangeDatabase(databaseName As String)
        Throw New NotSupportedException($"{NameOf(SQLiteProvider)} does not support databases, cannot change to {databaseName}.")
    End Sub

    Public Overrides Function GetMessage() As SqlMessage
        Throw New NotSupportedException($"{NameOf(SQLiteProvider)} does not support SqlMessages.")
    End Function

    Public Overrides Sub ClearMessages()
        Throw New NotSupportedException($"{NameOf(SQLiteProvider)} does not support SqlMessages.")
    End Sub
    Public Overrides ReadOnly Property HasMessages As Boolean
        Get
            Throw New NotSupportedException($"{NameOf(SQLiteProvider)} does not support SqlMessages.")
        End Get
    End Property
#End Region

#Region "Shared Functions"
    Public Shared Function Create(connDetail As ConnectionSQLite) As SQLiteProvider
        Dim connString As String
        If connDetail.HasConnectionString Then
            connString = connDetail.ConnectionString
        Else
            Dim sb As New SQLiteConnectionStringBuilder
            If Not connDetail.Database.Equals(":memory:", StringComparison.OrdinalIgnoreCase) Then
                Dim filepath = New IO.FileInfo(connDetail.Database)
                If Not filepath.Directory.Exists Then filepath.Directory.Create()
            End If

            sb.DataSource = connDetail.Database

            If Not String.IsNullOrWhiteSpace(connDetail.Password) Then sb.Password = connDetail.Password

            'Process additional parameters through the hashtable
            sb.AddHashtable(connDetail.Additional)
            connString = sb.ToString
        End If

        Return New SQLiteProvider(connDetail.ConnectionName, connDetail.CommandTimeout, New SQLiteConnection(connString))
    End Function
#End Region
End Class
