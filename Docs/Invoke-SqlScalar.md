---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Invoke-SqlScalar

## SYNOPSIS
Executes a Scalar query.

## SYNTAX

### object (Default)
```
Invoke-SqlScalar [-ConnectionName <String>] [-Query] <String[]> [-CommandTimeout <Int32>]
 [[-ParamObject] <PSObject>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### hashtable
```
Invoke-SqlScalar [-ConnectionName <String>] [-Query] <String[]> [-Parameters] <Hashtable>
 [-CommandTimeout <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Executes a Scalar query against the targeted connection.  If the sql statement generates multiple rows and/or columns, only the first column of the first row is returned.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-SqlScalar -Query "SELECT Count(1) FROM TABLE"
```

{{ Add example description here }}

## PARAMETERS

### -CommandTimeout
The timeout, in seconds, for this SQL statement, defaults to the command timeout for the SqlConnection.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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

### -Parameters
Parameters required by the query. Key matches the parameter name, Value is the value of the parameter.

```yaml
Type: Hashtable
Parameter Sets: hashtable
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParamObject
The object that contains the parameters for the query, member names match the parameter name.

```yaml
Type: PSObject
Parameter Sets: object
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Query
SQL statement to run.

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
Default value: default
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
