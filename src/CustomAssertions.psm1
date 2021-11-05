function Should-RunAfter ($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    [bool] $succeeded = $ActualValue.dependsOn -eq $ExpectedValue
    if ($Negate) { $succeeded = -not $succeeded }

    if (-not $succeeded) {
        if ($Negate) {
            $failureMessage = "Expected Stage '$ActualValue.stage' to not run after $ExpectedValue $(if($Because) { " because $Because"})."
        }
        else {
            $failureMessage = "Expected Stage '$ActualValue.stage' to run after $ExpectedValue $(if($Because) { " because $Because"})."
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

function Should-RunWhenPushTo ($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    [bool] $succeeded = $ActualValue.dependsOn -eq $ExpectedValue
    if ($Negate) { $succeeded = -not $succeeded }

    if (-not $succeeded) {
        if ($Negate) {
            $failureMessage = "Expected Stage '$ActualValue.stage' to not run after $ExpectedValue $(if($Because) { " because $Because"})."
        }
        else {
            $failureMessage = "Expected Stage '$ActualValue.stage' to run after $ExpectedValue $(if($Because) { " because $Because"})."
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

function Should-RunOnSuccessOrFailure ($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    [bool] $succeeded = $ActualValue.dependsOn -eq $ExpectedValue
    if ($Negate) { $succeeded = -not $succeeded }

    if (-not $succeeded) {
        if ($Negate) {
            $failureMessage = "Expected Stage '$ActualValue.stage' to not run after $ExpectedValue $(if($Because) { " because $Because"})."
        }
        else {
            $failureMessage = "Expected Stage '$ActualValue.stage' to run after $ExpectedValue $(if($Because) { " because $Because"})."
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
