$Dlls = @(
    #"Microsoft.Bcl.AsyncInterfaces.dll"
)

Foreach($dll in $Dlls) {
    Write-Host "Loading $dll ..." -NoNewline
    Add-Type -Path $dll
    Write-Host "Done!"
}
