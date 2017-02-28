Function ConvertToPSObject{
    Param([parameter(Mandatory)][System.Data.IDataRecord]$dr
        , [parameter(Mandatory)][SqlMap[]]$map)
    $ht = [ordered]@{}

    ForEach($m in $map){
        If($m.AllowNull -and $dr.IsDBNull($m.Ordinal)){
            $ht.Add($m.Name, $null)
        }
        Else {
            Switch($m.DataType) {
                "boolean" { $ht.Add($m.Name, $dr.GetBoolean($m.Ordinal)) }
            }
        }
    }
}