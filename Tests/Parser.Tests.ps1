BeforeAll {
    . $PSScriptRoot/Parser.ps1
}

Describe "Get-Expression" {
    It "Returns expected result for expression `"<Expression>`"" -ForEach @(
        @{
            Expression = '${{ if true }}:';

            Result = @{
                Type = "if";
                Expression = @(
                    "true"
                )
            }
        },

        @{
            Expression = '${{ if true }}:';

            Result = @{
                Type = "if";
                Expression = @(
                    "true"
                )
            }
        },

        @{
            Expression = '${{ if ne(stage.name, "NonProd") }}:';

            Result = @{
                Type = "if";
                Expression = @(
                    @{
                        Type = "ne";
                        Expression = @("stage.name", '"NonProd"')
                    }
                )
            }
        },

        @{
            Expression = '${{ if and(eq(stage.name, "NonProd"), ne(stage.level, 1)) }}:';

            Result = @{
                Type = "if";
                Expression = @(
                    @{
                        Type = "and"
                        Expression = @(
                            @{ Type = "eq"; Expression = @("stage.name", '"NonProd"')},
                            @{ Type = "ne"; Expression = @("stage.level", '1')}
                        )
                    }
                )
            }
        },

        @{
            Expression = '${{ if or(and(eq(stage.name, "NonProd"), not(eq(variables["Build.SourceBranchName"], "master"))), eq(variables["Build.SourceBranchName"], "master"))  }}:';

            Result = @{
                Type = "if";
                Expression = @(
                    @{
                        Type = "or"
                        Expression = @(
                            @{
                                Type = "and";
                                Expression = @(
                                    @{
                                        Type = "eq"
                                        Expression = @("stage.name", '"NonProd"')
                                    },

                                    @{
                                        Type = "not"
                                        Expression = @(
                                            @{
                                                Type = "eq"
                                                Expression = @('variables["Build.SourceBranchName"]', '"master"')
                                            }
                                        )
                                    }
                                )
                            },

                            @{
                                Type = "eq";
                                Expression = @('variables["Build.SourceBranchName"]', '"master"')
                            }
                        )
                    }
                )
            }
        }
    ) {
        $Value = Get-Expression $Expression

        ($Value | ConvertTo-Json -Depth 9) | Should -Be ($Result | ConvertTo-Json -Depth 9)
    }
}
