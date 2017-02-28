Function NoConnection([parameter(mandatory)][string]$ConnectionName) {
    If($ConnectionName -eq "Default") { return "There is no active SQL Connection."}
    Else { return "There is no active SQL connection ($ConnectionName)."}
}