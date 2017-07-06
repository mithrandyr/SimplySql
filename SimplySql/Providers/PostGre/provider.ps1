Class PostGreProvider : ProviderBase {
    
    PostGreProvider([string]$ConnectionName
                , [int]$CommandTimeout
                , [Npgsql.NpgsqlConnection]$Connection) {

        $this.ConnectionName = $ConnectionName
        $this.CommandTimeout = $CommandTimeout
        $this.Connection = $Connection

        $messages = $this.Messages
        $handler = {Param($sender, [Npgsql.NpgsqlNoticeEventArgs]$e)
            $messages.Enqueue(([SqlMessage]@{Received=(Get-Date); Message=$e.Notice.MessageText}))
        }.GetNewClosure()

        $this.Connection.add_Notice([Npgsql.NoticeEventHandler]$handler)
    }

    [string] ProviderType() { return "PostGre" }
    
    [PSCustomObject] ConnectionInfo() {
        return [PSCustomObject]@{
            ConnectionName = $this.ConnectionName
            ProviderType = $this.ProviderType()
            ConnectionState = $this.Connection.State
            ConnectionString = $this.Connection.ConnectionString
            ServerVersion = $this.Connection.ServerVersion
            Host = $this.Connection.Host
            Database = $this.Connection.Database
            CommandTimeout = $this.CommandTimeout
            HasTransaction = $this.HasTransaction()
        }
    }

    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd) {
        $ds = [System.Data.DataSet]::new()
        $da = [Npgsql.NpgsqlDataAdapter]::new($cmd)
        Try {
            $da.Fill($ds)
            return $ds 
        }
        Catch { Throw $_ }
        Finally { $da.dispose() }
    }
}
