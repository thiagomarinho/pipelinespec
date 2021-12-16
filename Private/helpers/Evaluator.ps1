function Get-FromContext {
    param (
        [String]
        $Reference,

        [Object]
        $Context
    )

    if ($Reference.Contains("variables[")) {
        return $Context.Variables[$Reference.Replace("variables[`"", "").Replace("`"]", "")]
    }

    return $Context.Parameters[$Reference]
}

function Evaluate-Expression {
    param (
        [Object]
        $Expression,

        [Object]
        $Context
    )
    # well... do it better
    if ($Expression -is [String]) {
        if ($Expression -eq "true") {
            return $true
        }

        if ($Expression -eq "false") {
            return $false
        }

        raise "Unexpected expression: ${Expression}"
    }

    if ($Expression.Type -eq 'if') {
        $EvaluatedValues = @()

        foreach ($InnerExpression in $Expression.Expression) {
            $EvaluatedValues += Evaluate-Expression -Expression $InnerExpression -Context $Context
        }

        return $EvaluatedValues.Count -and -not $EvaluatedValues.Contains($false)
    }

    if ($Expression.Type -eq 'ne') {
        $ValueFromExpression = $Expression.Expression[1]
        $ValueFromContext = Get-FromContext -Context $Context -Reference $Expression.Expression[0]

        if ($ValueFromExpression.StartsWith('"') -and $ValueFromExpression.EndsWith('"')) {
            $ValueFromContext = "`"${ValueFromContext}`""
        }

        return $ValueFromContext -ne $ValueFromExpression
    }

    if ($Expression.Type -eq 'eq') {
        $ValueFromExpression = $Expression.Expression[1]
        $ValueFromContext = Get-FromContext -Context $Context -Reference $Expression.Expression[0]

        if ($ValueFromExpression.StartsWith('"') -and $ValueFromExpression.EndsWith('"')) {
            $ValueFromContext = "`"${ValueFromContext}`""
        }

        return $ValueFromContext -eq $ValueFromExpression
    }

    if ($Expression.Type -eq 'not') {
        $ValueFromExpression = Evaluate-Expression -Expression $Expression.Expression[0] -Context $Context

        return -not $ValueFromExpression
    }

    if ($Expression.Type -eq 'and') {
        $ValuesFromExpression = ($Expression.Expression | ForEach-Object { Evaluate-Expression -Expression $_ -Context $Context })

        return $ValuesFromExpression.Contains($true) -and ($ValuesFromExpression | Select-Object -Unique ).Count -eq 1
    }

    if ($Expression.Type -eq 'or') {
        $ValuesFromExpression = ($Expression.Expression | ForEach-Object { Evaluate-Expression -Expression $_ -Context $Context })

        return $ValuesFromExpression.Contains($true)
    }

    throw "Unexpected expression Type: $($Expression.Type)"
}
