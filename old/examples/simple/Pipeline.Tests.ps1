Import-Module powershell-yaml

BeforeDiscovery {
    Import-Module "$PSScriptRoot/../../src/CustomAssertions.psm1" -DisableNameChecking
    Import-Module "$PSScriptRoot/../../src/CustomHelpers.psm1" -DisableNameChecking
    Import-Module "$PSScriptRoot/../../src/CustomAliases.psm1" -DisableNameChecking
}

Pipeline 'pipeline.yml' {
    BeforeAll {
        $Pipeline = Get-Pipeline 'pipeline.yml'
    }

    Stage 'Build' {
        BeforeAll {
            $Stage = Get-Stage 'Build' -Pipeline $Pipeline
        }

        Job 'SecurityScan' {
            BeforeAll {
                $Job = Get-Job 'SecurityScan' -Stage $Stage
            }

            It 'Runs when a push to master happens' {
                $Job | Should -RunWhenPushTo 'master'
            }

            Step 'Publish' {
                BeforeAll {
                    $Step = Get-Step 'Publish' -Job $Job
                }

                It 'Runs on success or failure' {
                    $Step | Should -RunOnSuccessOrFailure
                }
            }
        }
    }

    Stage 'DeployToDev' {
        BeforeAll {
            $Stage = Get-Stage 'DeployToDev' -Pipeline $Pipeline
        }

        It 'Runs after Build stage' {
            $Stage | Should -RunAfter 'Build'
        }
    }

    Stage 'DeployToCi' {
        BeforeAll {
            $Stage = Get-Stage 'DeployToCi' -Pipeline $Pipeline
        }

        It 'Runs after DeployToDev stage' {
            $Stage | Should -RunAfter 'DeployToDev'
        }
    }

    Stage 'DeployToStage' {
        BeforeAll {
            $Stage = Get-Stage 'DeployToStage' -Pipeline $Pipeline
        }

        It 'Runs after DeployToCi stage' {
            $Stage | Should -RunAfter 'DeployToCi'
        }
    }

    Stage 'DeployToProd' {
        BeforeAll {
            $Stage = Get-Stage 'DeployToProd' -Pipeline $Pipeline
        }

        It 'Runs after DeployToStage stage' {
            $Stage | Should -RunAfter 'DeployToStage'
        }
    }
}
