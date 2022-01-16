Import-Module "../../Pipelinespec.psm1"

# TODO evaluate conditional properties

Pipeline 'pipeline.yml' {
    BeforeAll {
        Set-PipelineContext
        Set-PipelineVariable -Name 'Build.SourceBranchName' -Value 'master'

        $Pipeline = Get-Pipeline 'pipeline.yml'
        Print-Pipeline $Pipeline
    }

    Stage 'DeployToDev' {
        BeforeAll {
            $Stage = Get-Stage 'DeployToDev' -Pipeline $Pipeline
        }

        It 'Points to prod environment' {
            Fetch-Property 'environment' -Stage $Stage | Should -Be 'nonprod'
        }
    }

    Stage 'DeployToProd' {
        BeforeAll {
            $Stage = Get-Stage 'DeployToProd' -Pipeline $Pipeline
        }

        It 'Points to prod environment' {
            Fetch-Property 'environment' -Stage $Stage | Should -Be 'PROD'
        }
    }
}
