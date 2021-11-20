function Should-RunAfter ($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    [bool] $succeeded = $ActualValue.dependsOn -eq $ExpectedValue
    if ($Negate) { $succeeded = -not $succeeded }

    if (-not $succeeded) {
        if ($Negate) {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to not run after $ExpectedValue $(if($Because) { " because $Because"})."
        }
        else {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to run after $ExpectedValue $(if($Because) { " because $Because"})."
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
    [bool] $succeeded = $ActualValue.condition -match $ExpectedValue
    if ($Negate) { $succeeded = -not $succeeded }

    if (-not $succeeded) {
        if ($Negate) {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to not run when happens a push to $ExpectedValue $(if($Because) { " because $Because"})."
        }
        else {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to run when happens a push to $ExpectedValue $(if($Because) { " because $Because"})."
        }
    }

    return [pscustomobject]@{
        Succeeded      = $succeeded
        FailureMessage = $failureMessage
    }
}

Add-ShouldOperator -Name RunWhenPushTo `
    -InternalName 'Should-RunWhenPushTo' `
    -Test ${function:Should-RunWhenPushTo}

function Should-RunOnSuccessOrFailure ($ActualValue, [switch] $Negate, [string] $Because) {
    [bool] $succeeded = $ActualValue.condition -match "succeededOrFailed()"
    if ($Negate) { $succeeded = -not $succeeded }

    if (-not $succeeded) {
        if ($Negate) {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to not run on success or failure $(if($Because) { " because $Because"})."
        }
        else {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to run on success or failure $(if($Because) { " because $Because"})."
        }
    }

    return [pscustomobject]@{
        Succeeded      = $succeeded
        FailureMessage = $failureMessage
    }
}

Add-ShouldOperator -Name RunOnSuccessOrFailure `
    -InternalName 'Should-RunOnSuccessOrFailure' `
    -Test ${function:Should-RunOnSuccessOrFailure}
