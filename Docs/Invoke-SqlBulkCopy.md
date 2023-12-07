---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Invoke-SqlBulkCopy

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### hashtable (Default)
```
Invoke-SqlBulkCopy [-SourceConnectionName <String>] [-DestinationConnectionName <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### table
```
Invoke-SqlBulkCopy [-SourceConnectionName <String>] [-DestinationConnectionName <String>]
 [-DestinationTable <String>] -SourceTable <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### query
```
Invoke-SqlBulkCopy [-SourceConnectionName <String>] [-DestinationConnectionName <String>]
 -DestinationTable <String> -SourceQuery <String[]> [-SourceParameters <Hashtable>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
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

### -DestinationConnectionName
{{ Fill DestinationConnectionName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: DstCN

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DestinationTable
{{ Fill DestinationTable Description }}

```yaml
Type: String
Parameter Sets: table
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: query
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceConnectionName
{{ Fill SourceConnectionName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: SrcCN

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceParameters
{{ Fill SourceParameters Description }}

```yaml
Type: Hashtable
Parameter Sets: query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceQuery
{{ Fill SourceQuery Description }}

```yaml
Type: String[]
Parameter Sets: query
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceTable
{{ Fill SourceTable Description }}

```yaml
Type: String
Parameter Sets: table
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.String[]

### System.Collections.Hashtable

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
