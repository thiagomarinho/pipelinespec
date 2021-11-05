function Evaluate-Steps {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Object]
        $Job,

        [Parameter(Mandatory = $true)]
        [Object]
        $Stage
    )

    # TODO

    return $Job['steps']
}
