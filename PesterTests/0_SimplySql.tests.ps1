Describe "ModuleLoad" {
    It "No Errors on Module Load" {
        $Error.Count | Should Be 0
    }

    It "At least 1 provider loaded" {
        Get-Command -Module SimplySql -Verb Open | Measure-Object | ForEach-Object Count | Should BeGreaterThan 0
    }
}
