function Should-RunAfter ([string] $ActualValue, [switch] $Negate, [string] $Because) {
  [bool] $succeeded = $false #$ActualValue -eq 'Build'
  if ($Negate) { $succeeded = -not $succeeded }

  if (-not $succeeded) {
      if ($Negate) {
          $failureMessage = "Expected Stage '$ActualValue' to not run after $(if($Because) { " because $Because"})."
      }
      else {
          $failureMessage = "Expected Stage '$ActualValue' to run after $(if($Because) { " because $Because"})."
      }
  }

  return [pscustomobject]@{
      Succeeded      = $succeeded
      FailureMessage = $failureMessage
  }
}

Add-ShouldOperator -Name RunAfter `
  -InternalName 'Should-RunAfter' `
  -Test ${function:Should-RunAfter}
