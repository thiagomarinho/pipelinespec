# https://stackoverflow.com/questions/59671144/perl-regex-to-get-comma-not-in-parenthesis-or-nested-parenthesis
function Get-Parameters {
    param (
        [string] $Expression
    )

    # return [regex]::split($Expression, '\,(?![^\(]*\))') | ForEach-Object { $_.Trim() }

    $Nesting = 0
    $Buffer = ''
    $Values = @()

    Select-String '\G([,()]|[^,()]+)' -input $Expression -AllMatches | ForEach-Object {
        foreach ($Match in $_.matches) {
            $Token = $Match.Value

            if ($Token -eq ',' -and -not $Nesting) {
                $Values += $Buffer
                $Buffer = ''
            } else {
                $Buffer += $Token

                if ($Token -eq '(') {
                    $Nesting++
                } elseif ($Token -eq ')') {
                    $Nesting--
                }
            }
        }

        if ($Buffer) {
            $Values += $Buffer
        }
    }

    # Write-Host $Values[0]
    # Write-Host '----'
    # Write-Host $Values[1]

    return $Values | ForEach-Object { $_.Trim() }
}

function Get-Expression {
    param (
        [string] $Expression
    )

    $EvaluatedExpression = @()

    if ($Expression.StartsWith('${{ if ')) {
        # it could end with either }} or }}:
        $ExpressionWithoutWrappers = $Expression.Replace('${{ if', '').Replace('}}:', '').Replace('}}', '').Trim()
        $Type = "if"

        if ($ExpressionWithoutWrappers.Contains("(")) {
            $EvaluatedExpression += Get-Expression $ExpressionWithoutWrappers
        } else {
            $EvaluatedExpression += $ExpressionWithoutWrappers
        }

        return @{
            Type = $Type;
            Expression = $EvaluatedExpression;
        }
    } else {
        # it will return true if we don`t do this
        $null = ($Expression -match '^([a-z]*)\(')

        $Type = $Matches[1]
    
        $KnownTypes = @('ne', 'eq', 'and', 'or', 'not')
    
        if (-not $KnownTypes.Contains($Type)) {
            throw "Unknown expression type ${Type}"
        }
    
        # Remove prefix and first (
        $InnerExpression = $Expression.Replace("${Type}(", "", 1)
    
        # Remove last )
        $InnerExpression = $InnerExpression -replace "(.*)\)(.*)", '$1$2'
    
        $Parameters = Get-Parameters $InnerExpression
    
        foreach($Parameter in $Parameters) {
            $Parameter = $Parameter.Trim()

            if ($Parameter.Contains("(")) {
                $EvaluatedExpression += Get-Expression $Parameter
            } else {
                $EvaluatedExpression += $Parameter
            }
        }
    
        return @{
            Type = $Type;
            Expression = $EvaluatedExpression
        }
    }
}
