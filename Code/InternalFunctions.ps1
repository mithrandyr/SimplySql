Function NoConnection([parameter(mandatory)][string]$ConnectionName) {
    If($ConnectionName -eq "Default") { return "There is no active SQL Connection."}
    Else { return "There is no active SQL connection ($ConnectionName)."}
}

Function ProcessHashTable([parameter(Mandatory)][hashtable]$ht) {
    If($ht) {
        ForEach($key in $ht.keys){
            If($ht.$key.GetType() -is [PSObject]) {
                $ht.$key = ([PSObject]($ht.$key)).BaseObject
            }
        }
    }
}

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

