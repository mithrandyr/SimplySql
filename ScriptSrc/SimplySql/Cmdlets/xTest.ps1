Function xTest([switch]$Enter) { 
    If($enter.IsPresent) {$host.EnterNestedPrompt()}
    Else {
        
    }
}
Export-ModuleMember -function xTest