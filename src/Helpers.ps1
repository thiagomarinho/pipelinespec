function Get-Pipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Filename
    )

    $Pipeline = ConvertFrom-Yaml (Get-Content $Filename -Raw)
    $Pipeline['_meta'] = @{
        Type = "Pipeline"
        Name = $Filename
    }

    $Pipeline['stages'] = Evaluate-Stages $Pipeline

    return $Pipeline
}

function Evaluate-Stages {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Object]
        $Pipeline
    )

    if () {
        
    } else 
        return $Pipeline['stages']
    }
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
    $Stage['_meta'] = @{
        Type = "Stage"
        Name = $Stage.Name
    }

    $Stage['jobs'] = Evaluate-Jobs $Stage -Pipeline $Pipeline

    return $Stage
}

function Evaluate-Jobs {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Object]
        $Stage,

        [Parameter(Mandatory = $true)]
        [Object]
        $Pipeline
    )

    # TODO

    return $Stage['jobs']
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
    $Job['_meta'] = @{
        Type = "Job"
        Name = $Job.job
    }

    $Job['steps'] = Evaluate-Steps $Job -Stage $Stage

    return $Job
}

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
    $Step['_meta'] = @{
        Type = "Step"
        Name = $Step.name
    }

    return $Step
}
