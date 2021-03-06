# For now is only working with compile time expressions
# https://docs.microsoft.com/en-us/azure/devops/pipelines/process/expressions?view=azure-devops
class Expression {
    [object] $Expression
    [object] $Value

    Expression([string] $Expression, [object] $Value) {
        $this.Expression = Get-Expression $Expression
        $this.Value = $Value
    }

    # XXX rename this?
    [object] Condition() {
        return $this.Expression
    }

    [object] InnerValue() {
        return $this.Value
    }

    [bool] Evaluate([object] $Context) {
        return Evaluate-Expression -Expression $this.Expression -Context $Context
    }
}
