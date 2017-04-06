InModuleScope SimplySql {
    Describe "Simply Sql Base" {
        It "No Errors on Module Load" {
            $Error.Count | Should Be 0
        }

        It "At least 1 provider loaded" {
            $Script:Providers.Count | Should BeGreaterThan 0
        }
    }
}