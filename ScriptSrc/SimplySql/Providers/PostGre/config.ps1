#Load Up PostGre libraries
Add-Type -Path "$PSScriptRoot\Npgsql.dll"
Add-Type -Path "$PSScriptRoot\Npgsql.NetTopologySuite.dll"

#Provider Class
. "$PSScriptRoot\provider.ps1"

#Open Cmdlet
Function Open-PostGreConnection {
    <#
    .Synopsis
        Open a connection to a PostGre Database.

    .Description
        Open a connection to a PostGre Database.
        
        PostGreSQL @ https://www.postgresql.org/
        PostGre via Npgsql @ http://www.npgsql.org/
        .NET Provider @ https://www.nuget.org/packages/Npgsql/
        Geometry: http://www.npgsql.org/doc/types/nts.html

    .Parameter ConnectionName
        The name to associate with the newly created connection.
        This connection will be used with other cmdlets when specifying
        -ConnectionName <name>.  If you don't specify one, it will be
        set to the default.

    .Parameter ConnectionString
        Specifies a provider specific connectionstring to be used.

    .Parameter CommandTimeout
        The default command timeout to be used for all commands executed against this connection.

    .Parameter Server
        The Server for the connection.

    .Parameter Database
        Database name.

    .Parameter Port
        Port to connect on, if different from default (5432).

    .Parameter UserName
        User to authenticate as.

    .Parameter Password
        Password for the user.

    .Parameter MaxAutoPrepare
        The maximum number SQL statements that can be automatically prepared at any
        given point. Beyond this number the least-recently-used statement will be
        recycled. Zero disables automatic preparation.  DEFAULTS TO 25.
    
    .Parameter RequireSSL
        This will change the SSLMode from 'prefer' to 'require'.

    .Parameter TrustSSL
        This will auto-accept the SSL certificate provided by the server, useful
        for self-signed certificate scenarios.

    #>
    [CmdletBinding(DefaultParameterSetName="default")]
    Param([Parameter(ValueFromPipelineByPropertyName)][Alias("cn")][string]$ConnectionName = "default"
        , [Parameter(ValueFromPipelineByPropertyName)][int]$CommandTimeout = 30
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=0)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass", Position=0)][string]$Server = "localhost"
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=1)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass", Position=1)][string]$Database ="postgres"
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default")]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass")][int]$Port = 5432
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="default")][pscredential]$Credential
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="userpass")][string]$UserName
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="userpass")][string]$Password
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default")]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass")][string]$MaxAutoPrepare = 25
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default")]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass")][switch]$RequireSSL
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default")]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass")][switch]$TrustSSL
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="Conn")][string]$ConnectionString)
    
    If($Script:Connections.ContainsKey($ConnectionName)) { Close-SqlConnection $ConnectionName }

    $sb = [Npgsql.NpgsqlConnectionStringBuilder]::new()
    $sb["Application Name"] = "PowerShell ({0})" -f $ConnectionName
    $sb["Max Auto Prepare"] = $MaxAutoPrepare

    If($PSCmdlet.ParameterSetName -eq "Conn") { $conn = [Npgsql.NpgsqlConnection]::new($ConnectionString) }
    Else {
        $sb.Server = $Server
        $sb.Database = $Database
        If($Port) { $sb.Port = $Port }
        
        If($Credential) {
            $sb.Username = $Credential.UserName
            $sb.Password = $Credential.GetNetworkCredential().Password
        }
        Else {
            Write-Warning "You are using -UserName and -Password, these options are deprecated and will be removed in the future.  Please consider using -Credential."
            $sb.Username = $UserName
            $sb.Password = $Password
        }

        If($RequireSSL) { $sb.SslMode = "Require" }
        Else { $sb.SslMode = "Prefer" }
        
        if($TrustSSL) { $sb["Trust Server Certificate"] = $true }
        
        $conn = [Npgsql.NpgsqlConnection]::new($sb.ConnectionString)
        $sb.Clear()
        $sb = $null
        Remove-Variable sb
    }    

    Try { $conn.Open() }
    Catch {
        $conn.Dispose()
        Throw $_
    }
    $Script:Connections.$ConnectionName = [PostGreProvider]::new($ConnectionName, $CommandTimeout, $conn)
}

Export-ModuleMember -Function Open-PostGreConnection