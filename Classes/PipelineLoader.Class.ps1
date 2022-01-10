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

        if ($Evaluated) {
            $ToBeReturned = @()

            foreach ($Thing in $Evaluated.GetEnumerator()) {
                # this means that we have a conditional block... right?
                if ($Thing.GetType().Name -eq 'hashtable') {
                    $IsConditionalBlock = $false

                    foreach ($Property in $Thing.GetEnumerator()) {
                        if ($Property.Name.StartsWith('${{')) {
                            $IsConditionalBlock = $true
                            break
                        }
                    }

                    $Block = $null

                    if ($IsConditionalBlock) {
                        $Expression = [Expression]::new($Property.Name, $Property.Value)

                        if ($Expression.Evaluate($Global:__PipelineContext)) {
                            $Block = $Property.Value[0]
                        }
                    } else {
                        $Block = $Thing
                    }

                    if ($Block) {
                        $Block = Evaluate-ConditionalProperties -Block $Block -Context $Context

                        $Block['_meta'] = @{
                            Type = $Type
                            Name = $Item.Name
                        }

                        $ToBeReturned += $Block
                    }
                } else {
                    $Evaluated = Evaluate-ConditionalProperties -Block $Evaluated -Context $Context

                    $Evaluated['_meta'] = @{
                        Type = $Type
                        Name = $Item.Name
                    }

                    $ToBeReturned += $Evaluated

                    break
                }
            }

            return $ToBeReturned
        }

        Write-Host "Couldn't find ${YamlKey}"

        return $null
    }
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

            $PipelineContext = @{
                Variables = $Global:__PipelineContext.Variables;
                Parameters = @{};
            }

            if ($Block['_meta'] -and $Block['_meta']['Parameters']) {
                $PipelineContext['Parameters'] = $Block['_meta']['Parameters']
            }

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
