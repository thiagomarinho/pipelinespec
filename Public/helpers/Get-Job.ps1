function Get-Job {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Name,

        [Parameter()]
        [Object]
        $Stage
    )

    $Job = $Stage.jobs | Where-Object { $_.job -eq $Name }

    if ($null -eq $Job) {
        throw "Job not found: ${Name}"
    }

    if (!$Job['_meta']) {
        $Job['_meta'] = @{}
    }

    $Job['_meta']['Type'] = 'Job'
    $Job['_meta']['Name'] = $Name

    $Job['steps'] = Evaluate-Steps $Job -Stage $Stage

    return $Job
}
