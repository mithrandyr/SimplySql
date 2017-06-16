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

    static [System.Data.IDbConnection] CreateConnection([hashtable]$ht) {
        If($ht.ParameterSetName -notin ("Default", "Conn")) { Throw [System.InvalidOperationException]::new("Invalid ParameterSet passed to CreateConnection") }
        
        $sb = [Oracle.ManagedDataAccess.Client.OracleConnectionStringBuilder]::new()

        If($ht.ContainsKey("ConnectionString")) { $sb["Connection String"] = $ht.ConnectionString }
        Else {
            $sb["Data Source"] = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST={0})(PORT={1}))(CONNECT_DATA=(SERVICE_NAME={2})))" -f $ht.DataSource, $ht.Port, $ht.ServiceName
            $sb["User Id"] = $ht.User
            $sb.Password = $ht.Password
            $sb["Statement Cache Size"] = 5
            If($ht.ContainsKey("DBAPrivilege")) { $sb["DBA Privilege"] = $ht.DBAPrivilege }
        }        
        
        $conn = [Oracle.ManagedDataAccess.Client.OracleConnection]::new($sb.ConnectionString)

        Try { $conn.Open() }
        Catch {
            $conn.Dispose()
            Throw $_
        }
        return $conn
    }    
}
