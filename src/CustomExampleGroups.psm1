function Pipeline {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Name,

    [Alias('Tags')]
    [string[]] $Tag = @(),

    [Parameter(Position = 1)]
    [ValidateNotNull()]
    [ScriptBlock] $Fixture,

    [Switch] $Skip
  )

  BeforeAll {
    $Pipeline = $Name
  }

  Describe -Name $Name -Tag $Tag -Fixture $Fixture
}

function Stage {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Name,

    [Alias('Tags')]
    [string[]] $Tag = @(),

    [Parameter(Position = 1)]
    [ValidateNotNull()]
    [ScriptBlock] $Fixture,

    [Switch] $Skip
  )

  Context -Name $Name -Tag $Tag {
    BeforeAll {
      $Stage = "Test"
      Write-Host "Stage:::: $Stage"
    }

    Invoke-Command -ScriptBlock $Fixture
  }
}

# Maybe I should just copy the Describe/Context instead of trying this ;(