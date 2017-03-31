Class SQLiteProvider : ProviderBase {
    
    SQLiteProvider([string]$ConnectionName
                , [int]$CommandTimeout
                , [System.Data.SQLite.SQLiteConnection]$Connection) {

        $this.ConnectionName = $ConnectionName
        $this.CommandTimeout = $CommandTimeout
        $this.Connection = $Connection
    }

    [string] ProviderType() { return "SQLite" }

    [PSCustomObject] ConnectionInfo() {
        return [PSCustomObject]@{
            ConnectionName = $this.ConnectionName
            ProviderType = $this.ProviderType()
            ConnectionState = $this.Connection.State
            ConnectionString = $this.Connection.ConnectionString
            ServerVersion = $this.Connection.ServerVersion
            DataSource = $this.Connection.DataSource
            CommandTimeout = $this.CommandTimeout
            HasTransaction = $this.HasTransaction()
        }
    }

    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd) {
        $ds = [System.Data.DataSet]::new()
        $da = [System.Data.SQLite.SQLiteDataAdapter]::new($cmd)
        Try {
            $da.Fill($ds)
            return $ds 
        }
        Finally { $da.dispose() }
    }

    [Void] GetMessage() { Write-Warning "SQLiteProvider does not support SqlMessages." }
    [Void] ClearMessages() { Write-Warning "SQLiteProvider does not support SqlMessages." }

    static [System.Data.IDbConnection] CreateConnection([hashtable]$ht) {
        If($ht.ParameterSetName -ne "Default") { Throw [System.InvalidOperationException]::new("Invalid ParameterSet passed to CreateConnection") }
        
        $sb = [System.Data.SQLite.SQLiteConnectionStringBuilder]::new()

        If($ht.ContainsKey("ConnectionString")) { $sb["Connection String"] = $ht.ConnectionString }
        Else {
            If($ht.ContainsKey("DataSource")) { $sb.Server = $ht.DataSource }
            If($ht.ContainsKey("Password")) { $sb.Password = $ht.Password }
        }        
        
        $conn = [System.Data.SQLite.SQLiteConnection]::new($sb.ConnectionString)

        Try { $conn.Open() }
        Catch {
            $conn.Dispose()
            Throw $_
        }
        return $conn
    }    
}
