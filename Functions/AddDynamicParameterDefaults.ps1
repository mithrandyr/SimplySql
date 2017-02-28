Function AddDynamicParameterDefaults {
    Param([Parameter(ValueFromPipeline)][System.Collections.Generic.Dictionary[string,object]]$Params)
    $Provider, $ParameterSetName = $Params.Provider, $Params.ParameterSetName
    
    ForEach($kvp in $Script:Providers.$Provider.Parameters.GetEnumerator()) {
        #$kvp.Value.Attributes
        If(-not $Params.ContainsKey($kvp.Key) -and
            $kvp.Value.IsSet #-and
            #$kvp.Value.Attributes.GetEnumerator()
            ) {
            $Params[$kvp.key] = $kvp.Value.Value
        }
    }
    Write-Output $Params
}