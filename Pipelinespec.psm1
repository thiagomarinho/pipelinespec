Import-Module powershell-yaml

Set-Alias -Name Pipeline -Value Describe
Set-Alias -Name Stage -Value Context
Set-Alias -Name Job -Value Context
Set-Alias -Name Step -Value Context

# ---
# assertions

function Should-RunAfter ($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    [bool] $succeeded = $ActualValue.dependsOn -eq $ExpectedValue
    if ($Negate) { $succeeded = -not $succeeded }

    if (-not $succeeded) {
        if ($Negate) {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to not run after $ExpectedValue $(if($Because) { " because $Because"})."
        }
        else {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to run after $ExpectedValue $(if($Because) { " because $Because"})."
        }
    }

    return [pscustomobject]@{
        Succeeded      = $succeeded
        FailureMessage = $failureMessage
    }
}

Add-ShouldOperator -Name RunAfter `
    -InternalName 'Should-RunAfter' `
    -Test ${function:Should-RunAfter}

function Should-RunWhenPushTo ($ActualValue, $ExpectedValue, [switch] $Negate, [string] $Because) {
    [bool] $succeeded = $ActualValue.condition -match $ExpectedValue
    if ($Negate) { $succeeded = -not $succeeded }

    if (-not $succeeded) {
        if ($Negate) {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to not run when happens a push to $ExpectedValue $(if($Because) { " because $Because"})."
        }
        else {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to run when happens a push to $ExpectedValue $(if($Because) { " because $Because"})."
        }
    }

    return [pscustomobject]@{
        Succeeded      = $succeeded
        FailureMessage = $failureMessage
    }
}

Add-ShouldOperator -Name RunWhenPushTo `
    -InternalName 'Should-RunWhenPushTo' `
    -Test ${function:Should-RunWhenPushTo}

function Should-RunOnSuccessOrFailure ($ActualValue, [switch] $Negate, [string] $Because) {
    [bool] $succeeded = $ActualValue.condition -match "succeededOrFailed()"
    if ($Negate) { $succeeded = -not $succeeded }

    if (-not $succeeded) {
        if ($Negate) {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to not run on success or failure $(if($Because) { " because $Because"})."
        }
        else {
            $failureMessage = "Expected $($ActualValue._meta.Type) '$($ActualValue._meta.Name)' to run on success or failure $(if($Because) { " because $Because"})."
        }
    }

    return [pscustomobject]@{
        Succeeded      = $succeeded
        FailureMessage = $failureMessage
    }
}

Add-ShouldOperator -Name RunOnSuccessOrFailure `
    -InternalName 'Should-RunOnSuccessOrFailure' `
    -Test ${function:Should-RunOnSuccessOrFailure}


# ---
# classes

class PipelineLoader {
    [string] $PipelineName
    [TemplateLoader] $TemplateLoader

    PipelineLoader(
        [string] $PipelineName
    ) {
        $this.PipelineName = $PipelineName
        $this.TemplateLoader = [TemplateLoader]::new()
    }

    [Object] Load() {
        $Pipeline = $this.LoadPipelineFromFile()

        $Pipeline['stages'] = $this.Evaluate($Pipeline, 'Stage', 'stages', @($Pipeline))

        foreach ($Stage in $Pipeline['stages']) {
            $Stage['jobs'] = $this.Evaluate($Stage, 'Job', 'jobs', @($Stage, $Pipeline))

            foreach ($Job in $Stage['jobs']) {
                $Job['steps'] = $this.Evaluate($Job, 'Step', 'steps', @($Job, $Stage, $Pipeline))
            }
        }

        return $Pipeline
    }

    [object] LoadPipelineFromFile() {
        $Pipeline = ConvertFrom-Yaml (Get-Content $this.PipelineName -Raw)

        $Pipeline['_meta'] = @{
            Type = "Pipeline"
            Name = $this.PipelineName
        }

        return $Pipeline
    }

    [object[]] Evaluate([object] $Item, [string] $Type, [string] $YamlKey, [array] $Context) {
        $Evaluated = $Item[$YamlKey] | ForEach-Object {
            if ($_['template']) {
                $this.TemplateLoader.Load($_, $Type, $YamlKey, $Context)
            } else {
                $_
            }
        }

        # $Evaluated['_meta'] = @{
        #     Type = $Type
        #     Name = $Item.Name
        # }

        return $Evaluated
    }
}

class TemplateLoader {
    [array] $RepoStack

    TemplateLoader() {
        $this.RepoStack = @(".")
    }

    [array] ParseTemplateMetadata([object] $Template, [array] $Context) {
        if ($this.IsRemoteTemplate($Template)) {
            return $Template['template'].Split('@')
        }

        $ItemWithMetadata = $Context | Where-Object { $null -ne $_['_meta'] -and $null -ne $_['_meta']['repo'] } | Select-Object -First 1 

        if ($null -ne $ItemWithMetadata) {
            return $Template['template'], $ItemWithMetadata['_meta']['repo']
        }

        return $Template['template'], '.'
    }

    [object] Load([object] $Template, [string] $Type, [string] $YamlKey, [array] $Context) {
        $TemplateName, $TemplateRepo = $this.ParseTemplateMetadata($Template, $Context)

        $YamlContent = $this.LoadTemplate($Template, $TemplateName, $TemplateRepo, $Type)

        # TODO validate parameters not found
        # TODO validate required parameters not defined

        foreach($Item in $YamlContent[$YamlKey]) {
            $Item['_meta'] = @{
                repo = $TemplateRepo
            }
        }

        return $YamlContent[$YamlKey]
    }

    [boolean] IsRemoteTemplate([object] $Template) {
        return $Template['template'].Contains("@")
    }

    [object] LoadTemplate([object] $Template, [string] $TemplateName, [string] $TemplateRepo, [string] $Type) {
        if ($TemplateRepo -eq '.') {
            $TemplateFile = $Template
        } else {
            $TemplateFile = "fixtures/${TemplateRepo}/${TemplateName}"
        }

        if (![System.IO.File]::Exists($TemplateFile)) {
            throw "Template not found: ${TemplateFile}"
        }

        $TemplateContent = Get-Content $TemplateFile -Raw

        if ($Template['parameters']) {
            foreach ($Parameter in $Template['parameters'].GetEnumerator()) {
                $TemplateContent = $TemplateContent.Replace("`${{ parameters.$($parameter.Name) }}", $Parameter.Value)
            }
        }

        return ConvertFrom-Yaml $TemplateContent
    }
}

# ---
# helpers

function Add-RemoteGitRepository {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $ResourceName,

        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $Url
    )

    Safe-CreateDir "./fixtures" 

    if (Test-Path "./fixtures/${ResourceName}") {
        if (Test-Path "./fixtures/${ResourceName}/.git") {
            git -C "./fixtures/${ResourceName}" pull
        } else {
            Write-Warning "Resource ${ResourceName} already exists at ./fixtures/${$ResourceName} and it's not a git repository"
        }
    } else {
        git clone $Url  "./fixtures/${ResourceName}"
    }
}

function Add-LocalDirectory {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [String]
        $Directory
    )

    Safe-CreateDir "./fixtures" 
    Safe-CopyDirRecursively -SourceDirectory $Directory -TargetDirectory "./fixtures/${ResourceName}"
}

function Safe-CreateDir {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Directory
    )

    if (!(Test-Path $Directory)) {
        New-Item $Directory -ItemType "Directory"
    } else {
        Write-Information "Directory ${Directory} already exists"
    }
}

function Safe-CopyDirRecursively {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $SourceDirectory,

        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $TargetDirectory
    )

    if (!(Test-Path $SourceDirectory)) {
        Write-Warning "Directory ${SourceDirectory} not found"
    } else {
        Copy-Item $SourceDirectory -Destination $TargetDirectory -Recurse
    }
}

function Get-Pipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Filename
    )

    return [PipelineLoader]::new($Filename).Load()
}

function Evaluate-Stages {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Object]
        $Pipeline
    )

    # TODO
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

    if ($null -eq $Stage) {
        throw "Stage not found: ${Name}"
    }

    $Stage['_meta'] = @{
        Type = "Stage"
        Name = $Name
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

    if ($null -eq $Job) {
        throw "Job not found: ${Name}"
    }

    $Job['_meta'] = @{
        Type = "Job"
        Name = $Name
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

    if ($null -eq $Step) {
        throw "Step not found: ${Name}"
    }

    $Step['_meta'] = @{
        Type = "Step"
        Name = $Name
    }

    return $Step
}


# ---