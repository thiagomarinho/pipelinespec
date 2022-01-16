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

    [String] GetConditionalKey([hashtable] $Evaluated) {
        if ($Evaluated.Count -eq 2) {
            if ($Evaluated._meta) {
                # TODO this can also be a foreach in the future

                return $Evaluated.Keys | Where-Object { $_.StartsWith('${{') }
            }
        }

        return $null
    }

    [object[]] GetItem([hashtable] $Evaluated, [object] $Item, [string] $Type, [array] $Context) {
        $Block = $null
        $ConditionalKey = $this.GetConditionalKey($Evaluated)

        if ($ConditionalKey) {
            $ConditionalBlock = $Evaluated[$ConditionalKey][0]

            $Expression = [Expression]::new($ConditionalKey, $ConditionalBlock)
            $PipelineContext = Get-PipelineContext $Evaluated

            if ($Expression.Evaluate($PipelineContext)) {
                $Block = $ConditionalBlock
                $Block._meta = $Evaluated._meta
            }
        } else {
            $Block = $Evaluated
        }

        if ($Block) {
            # now this is not working again
            $Block = Evaluate-ConditionalProperties -Block $Block -Context $Context

            if (!$Block['_meta']) {
                $Block['_meta'] = @{}
            }

            $Block['_meta']['Type'] = $Type
            $Block['_meta']['Name'] = $Item.Name # XXX not working
        }

        return $Block
    }

    [object[]] Evaluate([object] $Item, [string] $Type, [string] $YamlKey, [array] $Context) {
        $EvaluatedValues = $Item[$YamlKey] | ForEach-Object {    
            if ($_['template']) {
                $this.TemplateLoader.Load($_, $Type, $YamlKey, $Context)
            } else {
                $_
            }
        }

        if ($EvaluatedValues) {
            if ($EvaluatedValues.GetType().Name -eq 'hashtable' -or $EvaluatedValues -is [System.Collections.Hashtable]) {
                return $this.GetItem($EvaluatedValues, $Item, $Type, $Context)
            } else {
                $ToBeReturned = @()

                foreach ($EvaluatedValue in $EvaluatedValues) {
                    $ToBeReturned += $This.GetItem($EvaluatedValue, $Item, $Type, $Context)
                }

                return $ToBeReturned
            }
        }

        Write-Host "Couldn't find ${YamlKey}"

        return $null
    }
}

Function Get-PipelineContext {
    param (
        [hashtable]
        $Block
    )

    $PipelineContext = @{
        Variables = $Global:__PipelineContext.Variables;
        Parameters = @{};
    }

    if ($Block['_meta'] -and $Block['_meta']['Parameters']) {
        $PipelineContext['Parameters'] = $Block['_meta']['Parameters']
    }

    return $PipelineContext
}

Function Evaluate-ConditionalProperties {
    param (
        [hashtable]
        $Block,

        [array]
        $Context
    )

    $ValuesToAdd = @()
    $KeysToRemove = @()

    foreach ($Property in $Block.GetEnumerator()) {
        if ($Property.Name.StartsWith('${{')) {
            $KeysToRemove += $Property.Name

            $Expression = [Expression]::new($Property.Name, $Property.Value)

            $PipelineContext = Get-PipelineContext $Block

            if ($Expression.Evaluate($PipelineContext)) {
                foreach ($ValueToAdd in $Property.Value) {
                    $ValuesToAdd += $Property.Value
                }
            }
        }
    }

    foreach ($Key in $KeysToRemove) {
        $Block.Remove($Key)
    }

    foreach ($Value in $ValuesToAdd) {
        foreach ($Property in $Value.GetEnumerator()) {
            $Block[$Property.Key] = $Property.Value
        }
    }

    return $Block
}

Function Print-YamlBlock {
    param (
        [object]
        $Block,

        [string]
        $Color = "Cyan"
    )

    Write-Host '```' -ForegroundColor $Color
    Write-Host ($Block | ConvertTo-Yaml) -ForegroundColor $Color
    Write-Host '```' -ForegroundColor $Color
}
