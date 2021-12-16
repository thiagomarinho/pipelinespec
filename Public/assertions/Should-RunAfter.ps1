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
