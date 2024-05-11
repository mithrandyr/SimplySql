Imports System.Collections.Specialized
Imports System.Data
Imports System.Data.Common
Imports System.Runtime.CompilerServices
Imports System.Security.Cryptography
Imports NetTopologySuite.Geometries
Imports Npgsql

Public Class PostGreProvider
    Inherits ProviderBase

    Public Overloads ReadOnly Property Connection As NpgsqlConnection
        Get
            Return DirectCast(MyBase.Connection, NpgsqlConnection)
        End Get
    End Property

    Private Sub New(connectionName As String, commandTimeout As Integer, connection As NpgsqlConnection)
        MyBase.New(connectionName, ProviderTypes.PostGre, connection, commandTimeout)

        AddHandler Me.Connection.Notice, AddressOf HandleNoticeMessage
    End Sub

    Public Overrides Function ConnectionInfo() As OrderedDictionary
        Dim od = MyBase.ConnectionInfo
        With od
            .Add("ServerVersion", Connection.ServerVersion)
            .Add("Host", Connection.Host)
            .Add("Port", Connection.Port)
            .Add("Database", Connection.Database)
            .Add("User", Connection.UserName)
        End With
        Return od
    End Function

    Public Overrides Sub ChangeDatabase(databaseName As String)
        Connection.ChangeDatabase(databaseName)
    End Sub

    Public Overrides Function GetDataset(query As String, cmdTimeout As Integer, params As Hashtable, useProviderTypes As Boolean) As DataSet
        If Not useProviderTypes Then
            Return MyBase.GetDataset(query, cmdTimeout, params, False)
        Else
            Using cmd As NpgsqlCommand = GetCommand(query, cmdTimeout, params)
                Using da As New NpgsqlDataAdapter(cmd)
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

    Public Overrides Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Long)) As Long
        Dim iteration As Long = 0
        Using dataReader
            Dim schemaMap = GenerateSchemaMap(dataReader, columnMap)

            Dim copyFromSql As String = $"COPY {destinationTable} ({String.Join(", ", schemaMap.Select(Function(x) x.DestinationName))}) FROM STDIN (FORMAT BINARY)"
            Using bulk = Connection.BeginBinaryImport(copyFromSql)
                While dataReader.Read()
                    iteration += 1
                    bulk.StartRow()
                    For Each field In schemaMap
                        If dataReader.IsDBNull(field.Ordinal) Then
                            bulk.WriteNull()
                        Else
                            bulk.Write(dataReader.GetValue(field.Ordinal))
                        End If
                    Next

                    If notify IsNot Nothing Then
                        If iteration Mod batchSize = 0 Then
                            notify.Invoke(iteration)
                        End If
                    End If
                End While
                Return bulk.Complete()
            End Using
        End Using
    End Function

    Public Overrides Function HandleParamValue(x As Object) As Object
        If x.GetType().IsEnum Then x = DirectCast(x, Integer)
        Return MyBase.HandleParamValue(x)
    End Function

    Private Sub HandleNoticeMessage(sender As Object, e As NpgsqlNoticeEventArgs)
        Me.Messages.Enqueue(New SqlMessage(e.Notice.MessageText))
    End Sub

#Region "Shared Functions"
    Public Shared Function Create(connDetail As ConnectionPostGre) As PostGreProvider
        Dim sb As NpgsqlConnectionStringBuilder
        If connDetail.HasConnectionString Then
            sb = New NpgsqlConnectionStringBuilder(connDetail.ConnectionString)
        Else
            sb = New NpgsqlConnectionStringBuilder() With {
                    .ApplicationName = connDetail.ApplicationName,
                    .Host = connDetail.Host,
                    .Port = connDetail.Port,
                    .Database = connDetail.Database,
                    .MaxAutoPrepare = connDetail.MaxAutoPrepare,
                    .SslMode = MapSslMode(connDetail.SslMode)
                }

            'Process additional parameters through the hashtable
            sb.AddHashtable(connDetail.Additional)
        End If

        If connDetail.Credential IsNot Nothing Then
            sb.Username = connDetail.UserName
            sb.Password = connDetail.Password
        End If

        Dim dsBuilder As New NpgsqlDataSourceBuilder(sb.ToString)
        dsBuilder.UseNetTopologySuite()

        Return New PostGreProvider(connDetail.ConnectionName, connDetail.CommandTimeout, dsBuilder.Build.CreateConnection())
    End Function
    Private Shared Function MapSslMode(ssl As String) As SslMode
        Return [Enum].Parse(GetType(SslMode), ssl)
    End Function
#End Region
End Class
