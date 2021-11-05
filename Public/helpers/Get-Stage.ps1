function Get-Stage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Name,

        [Parameter()]
        [Object]
        $Pipeline
    )

    $Stage = $Pipeline.stages | Where-Object { $_.stage -eq $Name }

    if ($null -eq $Stage) {
        throw "Stage not found: ${Name}"
    }

    if (!$Stage['_meta']) {
        $Stage['_meta'] = @{}
    }

    $Stage['_meta']['Type'] = 'Stage'
    $Stage['_meta']['Name'] = $Name

    $Stage['jobs'] = Evaluate-Jobs $Stage -Pipeline $Pipeline

    return $Stage
}
