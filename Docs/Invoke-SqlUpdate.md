---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Invoke-SqlUpdate

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### hashtable (Default)
```
Invoke-SqlUpdate [-ConnectionName <String>] [-Query] <String[]> [[-Parameters] <Hashtable>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### object
```
Invoke-SqlUpdate [-ConnectionName <String>] [-Query] <String[]> [-ParamObject] <PSObject> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### cmd
```
Invoke-SqlUpdate [-ConnectionName <String>] [-Query] <String[]> -Command <IDbCommand> [-WhatIf] [-Confirm]
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

### -Command
{{ Fill Command Description }}

```yaml
Type: IDbCommand
Parameter Sets: cmd
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConnectionName
{{ Fill ConnectionName Description }}

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

### -Parameters
{{ Fill Parameters Description }}

```yaml
Type: Hashtable
Parameter Sets: hashtable
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParamObject
{{ Fill ParamObject Description }}

```yaml
Type: PSObject
Parameter Sets: object
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Query
{{ Fill Query Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
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

### System.Management.Automation.PSObject

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
