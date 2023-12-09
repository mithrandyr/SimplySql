---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Open-SQLConnection

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### default (Default)
```
Open-SQLConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Server] <String>]
 [[-Database] <String>] [-Additional <Hashtable>] [<CommonParameters>]
```

### credential
```
Open-SQLConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Server] <String>]
 [[-Database] <String>] [[-Credential] <PSCredential>] [-AzureAD] [-Additional <Hashtable>]
 [<CommonParameters>]
```

### token
```
Open-SQLConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Server] <String>]
 [[-Database] <String>] [-AzureToken <String>] [-Additional <Hashtable>] [<CommonParameters>]
```

### conn
```
Open-SQLConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Credential] <PSCredential>]
 [-AzureToken <String>] -ConnectionString <String> [<CommonParameters>]
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
Parameter Sets: default, credential, token
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AzureAD
{{ Fill AzureAD Description }}

```yaml
Type: SwitchParameter
Parameter Sets: credential
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AzureToken
{{ Fill AzureToken Description }}

```yaml
Type: String
Parameter Sets: token, conn
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
Default value: default
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
Parameter Sets: credential, conn
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Database
{{ Fill Database Description }}

```yaml
Type: String
Parameter Sets: default, credential, token
Aliases: SqlDatabase, InitialCatalog

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Server
{{ Fill Server Description }}

```yaml
Type: String
Parameter Sets: default, credential, token
Aliases: SqlInstance, SqlServer, DataSource

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Int32

### System.Management.Automation.PSCredential

### System.Management.Automation.SwitchParameter

### System.Collections.Hashtable

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
