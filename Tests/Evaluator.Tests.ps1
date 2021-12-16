BeforeAll {
    . $PSScriptRoot/Evaluator.ps1
}

Describe "Evaluate-Expression" {
    It "Returns expected result for expression `"<Expression>`"" -ForEach @(
        @{
            Expression = @{
                Type = "if";
                Expression = @(
                    "true"
                )
            };

            Context = @{};

            Result = $true;
        },

        @{
            Expression = @{
                Type = "if";
                Expression = @(
                    @{
                        Type = "eq";
                        Expression = @("stage.name", '"NonProd"')
                    }
                )
            }

            Context = @{
                Parameters = @{
                    "stage.name" = "NonProd"
                }
            };

            Result = $true;
        },

        @{
            Expression = @{
                Type = "if";
                Expression = @(
                    @{
                        Type = "ne";
                        Expression = @("stage.name", '"NonProd"')
                    }
                )
            }

            Context = @{
                Parameters = @{
                    "stage.name" = "Prod"
                }
            };

            Result = $true;
        },

        @{
            Expression = @{
                Type = "if";
                Expression = @(
                    @{
                        Type = "not"
                        Expression = @(
                            @{
                                Type = "eq";
                                Expression = @("stage.name", '"NonProd"')
                            }
                        )
                    }
                )
            }

            Context = @{
                Parameters = @{
                    "stage.name" = "NonProd"
                }
            };

            Result = $false;
        },

        @{
            Expression = @{
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
            };

            Context = @{
                Parameters = @{
                    "stage.name"  = "NonProd";
                    "stage.level" = 2;
                }
            }

            Result = $true;
        }

        @{
            Expression = @{
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
            };

            Context = @{
                Parameters = @{
                    "stage.name"  = "NonProd";
                };

                Variables = @{
                    "Build.SourceBranchName" = "master"
                };
            };

            Result = $true
        }
    ) {
        $Value = Evaluate-Expression -Expression $Expression -Context $Context

        $Value | Should -Be $Result
    }
}