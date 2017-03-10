[cmdletBinding()]
Param([switch]$Load)

If($Load) {
    $cmd = "{0}" -f $PSCmdlet.MyInvocation.MyCommand.Source
    PowerShell -noprofile -noexit -command $cmd
}
Else {
    Write-Host "In New PowerShell Session, [exit] to resume."
    $PSModuleAutoLoadingPreference = "none"
    Import-Module $PSScriptRoot -Force
    Get-Module SimplySql | Format-List

    Open-SqlConnection -DataSource it4 -InitialCatalog sandbox 

    Show-SqlConnection

    iss "print CAST(getdate() as time)
waitfor delay '00:00:01'
print cast(getdate() as time)

RAISERROR ('zero', 0, 1) --WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('one', 1, 1) --WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('two', 2, 1) --WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('three', 3, 1) --WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('four', 4, 1) --WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('five', 5, 1) --WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('six', 6, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('seven', 7, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('eight', 8, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('nine', 9, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('ten', 10, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('eleven', 1, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('twelve', 12, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('thirteen', 13, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('fourteen', 14, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('fifteen', 15, 1) WITH NOWAIT
waitfor delay '00:00:01'
RAISERROR ('sixteen', 16, 1) WITH NOWAIT"
    #Close-SqlConnection

    get-sqlmessage | Format-Table
}