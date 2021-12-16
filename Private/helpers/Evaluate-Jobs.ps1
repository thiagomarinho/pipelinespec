function Evaluate-Jobs {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Object]
        $Stage,

        [Parameter(Mandatory = $true)]
        [Object]
        $Pipeline
    )

    return $Stage['jobs']
}
