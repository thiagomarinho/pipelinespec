BeforeDiscovery {
  Import-Module "$PSScriptRoot/src/CustomAssertions.psm1" -DisableNameChecking
  Import-Module "$PSScriptRoot/src/CustomHelpers.psm1" -DisableNameChecking
  Import-Module "$PSScriptRoot/src/CustomAliases.psm1" -DisableNameChecking
}

Describe 'pipeline.yml' {
  BeforeAll {
    Write "TestName: $TestName"
    $Pipeline = 'pipeline.yml'
  }

  Context 'DeployToDev' {
    BeforeAll {
      $Stage = Get-Stage -Pipeline $Pipeline -Stage 'DeployToDev'
    }

    It 'Runs after Build' {
      $Stage | Should -RunAfter 'Build'
    }
  }
}
