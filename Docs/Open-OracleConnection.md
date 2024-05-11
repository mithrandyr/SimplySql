---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Open-OracleConnection

## SYNOPSIS
Open a connection to a Oracle Database.

## SYNTAX

### default (Default)
```
Open-OracleConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Server] <String>]
 [[-ServiceName] <String>] [-Port <Int32>] [-Privilege <String>] [[-Credential] <PSCredential>]
 [-Additional <Hashtable>] [<CommonParameters>]
```

### tns
```
Open-OracleConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] -TnsName <String>
 [-Privilege <String>] [[-Credential] <PSCredential>] [-Additional <Hashtable>] [<CommonParameters>]
```

### conn
```
Open-OracleConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [-Privilege <String>]
 -ConnectionString <String> [<CommonParameters>]
```

## DESCRIPTION
Open a connection to a Oracle Database.
        
Oracle Managed Data Access @ http://www.oracle.com/technetwork/topics/dotnet/index-085163.html
Provider for .NET @ https://www.nuget.org/packages/Oracle.ManagedDataAccess

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Additional
Hashtable to provide additional connection parameters.

```yaml
Type: Hashtable
Parameter Sets: default, tns
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CommandTimeout
The default command timeout to be used for all commands executed against this connection.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 30
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConnectionName
User defined name for connection.

```yaml
Type: String
Parameter Sets: (All)
Aliases: cn

Required: False
Position: Named
Default value: default
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConnectionString
Specifies a provider specific connectionstring to be used.

```yaml
Type: String
Parameter Sets: conn
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
A PSCredential object providing the proper credentials to access to the datasource (if required).

```yaml
Type: PSCredential
Parameter Sets: default, tns
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Port
Port to connect on, if different from default (1521).

```yaml
Type: Int32
Parameter Sets: default
Aliases:

Required: False
Position: Named
Default value: 1521
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Privilege
Determines the elevated privileges the connection has: SYSDBA, SYSOPER, SYSASM.  By default, none.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: None, SYSDBA, SYSOPER, SYSASM

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Server
The datasource for the connection.

```yaml
Type: String
Parameter Sets: default
Aliases: Host, DataSource

Required: False
Position: 0
Default value: localhost
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ServiceName
Oracle ServiceName (SID).

```yaml
Type: String
Parameter Sets: default
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TnsName
The TnsName to connect to.

```yaml
Type: String
Parameter Sets: tns
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Int32
### SimplySql.Common.ConnectionOracle+OraclePrivilege
### System.Management.Automation.PSCredential
### System.Collections.Hashtable
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
