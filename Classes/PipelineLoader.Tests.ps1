BeforeAll {
  Write-Host $PSCommandPath.Replace('.Tests.ps1','.Class.ps1')
  . $PSScriptRoot/Expression.Class.ps1
  . $PSScriptRoot/TemplateLoader.Class.ps1
  . $PSScriptRoot/../Private/helpers/Parser.ps1
  . $PSScriptRoot/../Private/helpers/Evaluator.ps1
  . $PSScriptRoot/../Private/helpers/Evaluate-Jobs.ps1
  . $PSScriptRoot/../Private/helpers/Evaluate-Steps.ps1
  . $PSScriptRoot/../Public/helpers/Print-Pipeline.ps1
  . $PSScriptRoot/../Public/helpers/Get-Stage.ps1
  . $PSScriptRoot/../Public/helpers/Get-Job.ps1
  . $PSScriptRoot/../Public/helpers/Set-PipelineVariable.ps1
  . $PSScriptRoot/../Public/helpers/Set-PipelineContext.ps1
  . $PSCommandPath.Replace('.Tests.ps1','.Class.ps1')
}

Describe "PipelineLoader" {
  BeforeAll {
    $SimplePipelineTrueFilePath = "TestDrive:\simple-pipeline-true.yml"
    $SimplePipelineFalseFilePath = "TestDrive:\simple-pipeline-false.yml"
    $SimpleContextWithVariableFilePath = "TestDrive:\simple-context-variable.yml"

    # Defining context parameter from pipeline
    $SimplePipelineUsingTemplateWithParameterDev = "TestDrive:\simple-pipeline-parameter-dev.yml"
    $SimplePipelineUsingTemplateWithParameterPr = "TestDrive:\simple-pipeline-parameter-pr.yml"
    $SimpleTemplateWithParameterFilePath = "./_test_template/simple-template.yml"

    # TODO: define context variable from pipeline
    # TODO: evaluate condition parameter

    # TODO but probably not here: validate if dependsOn exists

    Set-Content $SimplePipelineTrueFilePath -value @'
pool:
  vmImage: 'ubuntu-latest'

stages:
  - ${{ if true }}:
    - stage: Build
      jobs:
        - job: Build
          steps:
            - bash: echo "Hello world"
  - stage: Deploy
    jobs:
      - job: Sample
        steps:
          - bash: echo "Hi"
'@

    Set-Content $SimplePipelineFalseFilePath -value @'
pool:
  vmImage: 'ubuntu-latest'

stages:
  - ${{ if false }}:
    - stage: Build
      jobs:
        - job: Build
          steps:
            - bash: echo "Hello world"
  - stage: Deploy
    jobs:
      - job: Sample
        steps:
          - bash: echo "Hi"
'@

    Set-Content $SimpleContextWithVariableFilePath -value @'
pool:
  vmImage: 'ubuntu-latest'

stages:
  - ${{ if eq(variables['build.sourceBranch'], 'refs/heads/master') }}:
    - stage: Build
      jobs:
        - job: Build
          steps:
            - bash: echo "Hello world"
  - stage: Deploy
    jobs:
      - job: Sample
        steps:
          - bash: echo "Hi"
'@

    Set-Content $SimplePipelineUsingTemplateWithParameterDev -value @"
stages:
- template: ${SimpleTemplateWithParameterFilePath}
  parameters:
    environment: Dev
    dependsOn: Build
"@

    Set-Content $SimplePipelineUsingTemplateWithParameterPr -value @"
stages:
- template: ${SimpleTemplateWithParameterFilePath}
  parameters:
    environment: Pr
    dependsOn: Build
"@
  }

  Context "With simple condition resolved as true" {
    It "Should include inner block" {
      $Pipeline = [PipelineLoader]::new($SimplePipelineTrueFilePath).Load()

      Print-Pipeline $Pipeline
    
      $Pipeline.stages[0].stage | Should -Be "Build"
      $Pipeline.stages[1].stage | Should -Be "Deploy"
    }
  }

  Context "With simple condition resolved as false" {
    It "Should include inner block" {
      $Pipeline = [PipelineLoader]::new($SimplePipelineFalseFilePath).Load()

      Print-Pipeline $Pipeline
    
      $Pipeline.stages[0].stage | Should -Be "Deploy"
      $Pipeline.stages[1] | Should -Be $null

      $Stage = Get-Stage 'Deploy' -Pipeline $Pipeline
      $Job = Get-Job 'Sample' -Stage $Stage

      $Job.job | Should -Be "Sample"
    }
  }

  Context "With simple condition relying on context variable resolved as true" {
    It "Should include inner block" {
      Set-PipelineContext
      Set-PipelineVariable -Name "build.sourceBranch" -Value "refs/heads/master"

      $Pipeline = [PipelineLoader]::new($SimpleContextWithVariableFilePath).Load()

      Print-Pipeline $Pipeline
    
      $Pipeline.stages[0].stage | Should -Be "Build"
      $Pipeline.stages[1].stage | Should -Be "Deploy"
    }
  }

  Context "With simple condition relying on context variable resolved as false" {
    It "Should not include inner block" {
      Set-PipelineContext
      Set-PipelineVariable -Name "build.sourceBranch" -Value "refs/heads/dev"

      $Pipeline = [PipelineLoader]::new($SimpleContextWithVariableFilePath).Load()

      Print-Pipeline $Pipeline
    
      $Pipeline.stages[0].stage | Should -Be "Deploy"
      $Pipeline.stages[1] | Should -Be $null
    }
  }

  Context "With simple condition relying on context parameter resolved as null" {
    It "Should have expected properties" {
      Set-PipelineContext
      $Pipeline = [PipelineLoader]::new($SimplePipelineUsingTemplateWithParameterDev).Load()

      Print-Pipeline $Pipeline

      $Pipeline.stages[0].stage | Should -Be "DeployToDev"
      $Pipeline.stages[0].dependsOn | Should -Be "Build"
      $Pipeline.stages[0]["`${{ if eq(parameters['environment'], 'Pr') }}:"] | Should -Be $null
      $Pipeline.stages[0].environment | Should -Be $null
    }
  }

  Context "With simple condition relying on context parameter resolved as PROD" {
    It "Should have expected properties" {
      Set-PipelineContext
      $Pipeline = [PipelineLoader]::new($SimplePipelineUsingTemplateWithParameterPr).Load()

      Print-Pipeline $Pipeline

      $Pipeline.stages[0].stage | Should -Be "DeployToPr"
      $Pipeline.stages[0].dependsOn | Should -Be "Build"
      $Pipeline.stages[0].environment | Should -Be "PROD"
    }
  }
}
