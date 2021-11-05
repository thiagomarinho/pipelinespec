function Get-Pipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Filename
    )

    $Yaml = Get-Content $Filename -Raw
    $Content = ConvertFrom-Yaml $Yaml

    return $Content
}

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

    return $Stage
}

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

    return $Job
}

function Get-Step {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Name,

        [Parameter()]
        [Object]
        $Job
    )

    # TODO step, task, bash, pwsh...
    $Step = $Job.steps | Where-Object { $_.name -eq $Name }

    return $Step
}
