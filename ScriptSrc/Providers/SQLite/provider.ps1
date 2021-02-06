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

    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd, [Boolean]$ProviderTypes) {
        $ds = [System.Data.DataSet]::new()
        $da = [System.Data.SQLite.SQLiteDataAdapter]::new($cmd)
        if ($ProviderTypes) {
            $da.ReturnProviderSpecificTypes = $true
        }
        Try {
            $da.Fill($ds)
            return $ds 
        }
        Catch { Throw $_ }
        Finally { $da.dispose() }
    }

    [Void] GetMessage() { Write-Warning "SQLiteProvider does not support SqlMessages." }
    [Void] ClearMessages() { Write-Warning "SQLiteProvider does not support SqlMessages." }
}