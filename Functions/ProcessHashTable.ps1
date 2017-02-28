Function ProcessHashTable([parameter(Mandatory)][hashtable]$ht) {
    If($ht) {
        ForEach($key in $ht.keys){
            If($ht.$key.GetType() -is [PSObject]) {
                $ht.$key = ([PSObject]($ht.$key)).BaseObject
            }
        }
    }
}