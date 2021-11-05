function Get-Step {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Name,

        [Object]
        $Job
    )

    # TODO step, task, bash, pwsh...
    $Step = $Job.steps | Where-Object { $_.name -eq $Name }

    if ($null -eq $Step) {
        throw "Step not found: ${Name}"
    }

    if (!$Step['_meta']) {
        $Step['_meta'] = @{}
    }

    $Step['_meta']['Type'] = 'Step'
    $Step['_meta']['Name'] = $Name

    return $Step
}
