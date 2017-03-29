Function CreateMapFunction {
    Param([Parameter(Mandatory)][System.Data.DataTable]$SchemaTable)

    $sb = [System.Text.StringBuilder]::new()

    $sb.AppendLine('Param([parameter(Mandatory)][System.Data.IDataRecord]$dr)') | Out-Null
    $sb.AppendLine('Return ([PSCustomObject]@{') | Out-Null
    
    ForEach($dr in $SchemaTable.Rows) {
        [string]$colName = $dr["ColumnName"]
        [int]$colOrdinal = $dr["ColumnOrdinal"]
        If([string]::IsNullOrWhiteSpace($colName)) { $colName = "Column{0}" -f ($colOrdinal + 1)}

        [string]$colFunction = Switch($dr["DataType"].Name) {
                "Boolean" { "GetBoolean" }
                "Byte" { "GetByte" }
                "Char" { "GetChar" }
                "Datetime" { "GetDateTime" }
                "Decimal" { "GetDecimal" }
                "Double" { "GetDouble" }
                "Single" { "GetFloat" }
                "Guid" { "GetGuid" }
                "Int16" { "GetInt16" }
                "Int32" { "GetInt32" }
                "Int64" { "GetInt64" }
                "String" { "GetString" }
                Default { "GetValue" }
            }

        If($dr["AllowDBNull"]) {
            $sb.AppendLine(('  {0} = if($dr.IsDBNull({2})) {{$null}} else {{$dr.{1}({2})}}' -f $colName, $colFunction, $colOrdinal)) | Out-Null
        }
        Else {
            $sb.AppendLine(('  {0} = $dr.{1}({2})' -f $colName, $colFunction, $colOrdinal)) | Out-Null
        }
    }

    $sb.AppendLine('})') | Out-Null
    Return ([scriptblock]::Create($sb.ToString()))
}