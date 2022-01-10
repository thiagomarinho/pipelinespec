function Get-FromContext {
    param (
        [String]
        $Reference,

        [Object]
        $Context
    )

    if ($Context -eq $null) {
        throw "Context not initialized. Please make sure you are calling Set-PipelineContext"
    }

    if ($Reference.Contains("variables[")) {
        $Key = $Reference.Replace("variables[`"", "").Replace("`"]", "").Replace("variables['", "").Replace("']", "")
        return $Context.Variables[$Key]
    }

    if ($Reference.Contains("parameters[")) {
        $Key = $Reference.Replace("parameters[`"", "").Replace("`"]", "").Replace("parameters['", "").Replace("']", "")
        return $Context.Parameters[$Key]
    }

    throw "Unexpected reference: ${Reference}"
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

        throw "Unexpected expression: ${Expression}"
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

        if ($ValueFromExpression.StartsWith("'") -and $ValueFromExpression.EndsWith("'")) {
            $ValueFromContext = "'${ValueFromContext}'"
        }

        return $ValueFromContext -ne $ValueFromExpression
    }

    if ($Expression.Type -eq 'eq') {
        $ValueFromExpression = $Expression.Expression[1]
        $ValueFromContext = Get-FromContext -Context $Context -Reference $Expression.Expression[0]

        if ($ValueFromExpression.StartsWith('"') -and $ValueFromExpression.EndsWith('"')) {
            $ValueFromContext = "`"${ValueFromContext}`""
        }

        if ($ValueFromExpression.StartsWith("'") -and $ValueFromExpression.EndsWith("'")) {
            $ValueFromContext = "'${ValueFromContext}'"
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
