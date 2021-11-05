class TemplateLoader {
    [array] ParseTemplateMetadata([object] $Template, [array] $Context) {
        if ($this.IsRemoteTemplate($Template)) {
            return $Template['template'].Split('@')
        }

        $ItemWithMetadata = $Context | Where-Object { $_['_meta'] -and $_['_meta']['repo'] } | Select-Object -First 1

        if ($ItemWithMetadata) {
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
            if ($YamlContent['_meta'] -and $YamlContent['_meta']['Parameters']) {
                if (!$Item['_meta']) {
                    $Item['_meta'] = @{}
                }

                $Item['_meta']['Parameters'] = $YamlContent['_meta']['Parameters']
            }

            $PossibleContentWithMetadata = @('stages', 'jobs', 'steps')

            foreach ($PossibleContent in $PossibleContentWithMetadata) {
                if ($Item[$PossibleContent]) {
                    
                    foreach ($InnerItem in $Item[$PossibleContent]) {
                        $InnerItem['_meta'] = @{
                            repo = $TemplateRepo
                        }
                    }
                }
            }
        }

        return $YamlContent[$YamlKey]
    }

    [boolean] IsRemoteTemplate([object] $Template) {
        return $Template['template'].Contains("@")
    }

    [object] LoadTemplate([object] $Template, [string] $TemplateName, [string] $TemplateRepo, [string] $Type) {
        if ($TemplateRepo -eq '.') {
            $TemplateFile = $TemplateName
        } else {
            $TemplateFile = "fixtures/${TemplateRepo}/${TemplateName}"
        }

        if (![System.IO.File]::Exists($TemplateFile)) {
            throw "Template not found: ${TemplateFile}"
        }

        $TemplateContent = Get-Content $TemplateFile -Raw

        if ($Template['parameters']) {
            foreach ($Parameter in $Template['parameters'].GetEnumerator()) {
                $TemplateContent = $TemplateContent.Replace("`${{ parameters.$($Parameter.Name) }}", $Parameter.Value)
            }
        }

        $Converted = ConvertFrom-Yaml $TemplateContent

        $Converted['_meta'] = @{
            Parameters = @{}
        }

        if ($Template['parameters']) {
            foreach ($Parameter in $Template['parameters'].GetEnumerator()) {
                $Converted['_meta']['parameters'][$Parameter.Name] = $Parameter.Value
            }
        }

        return $Converted
    }
}
