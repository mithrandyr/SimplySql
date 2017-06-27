# consider adding custom bulk implementation using array binding
# http://www.oracle.com/technetwork/issue-archive/2009/09-sep/o59odpnet-085168.html
Class OracleProvider : ProviderBase {
    
    [string]$ParamPrefix = ":"

    OracleProvider([string]$ConnectionName
                , [int]$CommandTimeout
                , [Oracle.ManagedDataAccess.Client.OracleConnection]$Connection) {

        $this.ConnectionName = $ConnectionName
        $this.CommandTimeout = $CommandTimeout
        $this.Connection = $Connection

        $messages = $this.Messages
        $handler = {Param($sender, [Oracle.ManagedDataAccess.Client.OracleInfoMessageEventArgs]$e)
            $messages.Enqueue(([SqlMessage]@{Received=(Get-Date); Message=$e.Message}))
        }.GetNewClosure()

        $this.Connection.add_InfoMessage([Oracle.ManagedDataAccess.Client.OracleInfoMessageEventHandler]$handler)
    }

    [string] ProviderType() { return "Oracle" }
    
    [PSCustomObject] ConnectionInfo() {
        return [PSCustomObject]@{
            ConnectionName = $this.ConnectionName
            ProviderType = $this.ProviderType()
            ConnectionState = $this.Connection.State
            ConnectionString = $this.Connection.ConnectionString
            ServerVersion = $this.Connection.ServerVersion
            HostName = $this.Connection.HostName
            ServiceName = $this.Connection.ServiceName
            CommandTimeout = $this.CommandTimeout
            HasTransaction = $this.HasTransaction()
        }
    }

    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd) {
        $ds = [System.Data.DataSet]::new()
        $da = [Oracle.ManagedDataAccess.Client.OracleDataAdapter]::new($cmd)
        Try {
            $da.Fill($ds)
            return $ds 
        }
        Catch { Throw $_ }
        Finally { $da.dispose() }
    }
}
