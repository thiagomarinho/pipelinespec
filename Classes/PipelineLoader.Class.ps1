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

        # TODO this will be moved from here later
        foreach ($Thing in $Evaluated.GetEnumerator()) {
            if ($Thing.GetType().Name -eq 'hashtable') {
                $Thing['_meta'] = @{
                    Type = $Type
                    Name = $Item.Name
                }

                foreach ($Property in $Thing.GetEnumerator()) {
                    if ($Property.Name.StartsWith('${{')) {
                        $Expression = [Expression]::new($Property)

                        $Context = @{
                            Parameters = @{};
                            Variables = @{};
                        }

                        Write-Host $Expression.Condition().Type
                        Write-Host $Expression.Condition().Expression.Count
                        Write-Host $Expression.Evaluate($Context)
                    }
                }
            }
            # elseif ($Thing.GetType().Name -eq 'DictionaryEntry') {
            #     Write-Host $Thing.Key
            # }
        }

        return $Evaluated
    }
}
