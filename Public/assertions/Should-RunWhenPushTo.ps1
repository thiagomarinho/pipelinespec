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
