BeforeDiscovery {
  Import-Module "$PSScriptRoot/src/CustomExampleGroups.psm1" -DisableNameChecking
  Import-Module "$PSScriptRoot/src/CustomAssertions.psm1" -DisableNameChecking
}

# Pipeline 'pipeline.yml' {
#   Stage 'DeployToDev' {
#     It 'Runs after Build' {
#       $Stage | Should -Be 'Bldui'
#       Should -RunAfter 'Build'
#     }
#   }
# }

Describe 'pipeline.yml' {
  BeforeAll {
    $Pipeline = 'pipeline.yml'
  }

  Context 'DeployToDev' {
    BeforeAll {
      #$Stage = Get-Stage -Pipeline $Pipeline -Stage 'DeployToDev'
      $stage = 'DeployToDev'
    }

    It 'Runs after Build' {
      $Stage | Should -Be 'Bldui'
      Should -RunAfter 'Build'
    }
  }
}

