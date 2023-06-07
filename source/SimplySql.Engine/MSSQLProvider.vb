Imports System.Collections.Specialized
Imports System.Data
Imports System.Data.SqlClient
Imports System.Data.SQLite
Imports System.Runtime.CompilerServices

Public Class MSSQLProvider
    Inherits ProviderBase

    Public Sub New(connectionName As String, commandTimeout As Integer, connection As SQLiteConnection)
        MyBase.New(connectionName, ProviderTypes.MSSQL, connection, commandTimeout)

        AddHandler Me.Connection.InfoMessage, AddressOf HandleInfoMessage
    End Sub

    Public Overloads ReadOnly Property Connection As SqlConnection
        Get
            Return DirectCast(MyBase.Connection, SqlConnection)
        End Get
    End Property

    Public Overrides Function ConnectionInfo() As OrderedDictionary
        Dim od = MyBase.ConnectionInfo
        With od
            .Add("ServerVersion", Connection.ServerVersion)
            .Add("Server", Connection.DataSource)
            .Add("Database", Connection.Database)
        End With
        Return od
    End Function

    Public Overrides Sub ChangeDatabase(databaseName As String)
        Me.Connection.ChangeDatabase(databaseName)
    End Sub

    Public Overrides Function GetDataset(query As String, cmdTimeout As Integer, params As Hashtable, useProviderTypes As Boolean) As DataSet
        If Not useProviderTypes Then
            Return MyBase.GetDataset(query, cmdTimeout, params, useProviderTypes)
        Else

        End If
    End Function

    Private Sub HandleInfoMessage(sender As Object, e As SqlInfoMessageEventArgs)
        Me.Messages.Enqueue(New SqlMessage(e.Message))
    End Sub
End Class
