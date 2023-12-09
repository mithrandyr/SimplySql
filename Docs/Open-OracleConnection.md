---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Open-OracleConnection

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### default (Default)
```
Open-OracleConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Server] <String>]
 [[-ServiceName] <String>] [-Port <Int32>] [-Privilege <OraclePrivilege>] [[-Credential] <PSCredential>]
 [-Additional <Hashtable>] [<CommonParameters>]
```

### tns
```
Open-OracleConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] -TnsName <String>
 [-Privilege <OraclePrivilege>] [[-Credential] <PSCredential>] [-Additional <Hashtable>] [<CommonParameters>]
```

### conn
```
Open-OracleConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [-Privilege <OraclePrivilege>]
 -ConnectionString <String> [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Additional
{{ Fill Additional Description }}

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
{{ Fill CommandTimeout Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConnectionString
{{ Fill ConnectionString Description }}

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
{{ Fill Credential Description }}

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
{{ Fill Port Description }}

```yaml
Type: Int32
Parameter Sets: default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Privilege
{{ Fill Privilege Description }}

```yaml
Type: OraclePrivilege
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
{{ Fill Server Description }}

```yaml
Type: String
Parameter Sets: default
Aliases: Host

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ServiceName
{{ Fill ServiceName Description }}

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
{{ Fill TnsName Description }}

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
