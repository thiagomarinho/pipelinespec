# Pre-requisites

- Install-Module Pester
- Install-Module powershell-yaml
- git

# Usage

Install-Module Pipelinespec
Import-Module Pipelinespec

./Pipeline.Tests.ps1

# Development/testing

# Known limitations
- for each template not supported yet

- you can not use the same key twice:
[-] Describe pipeline.yml failed
 ArgumentException: An item with the same key has already been added. Key: ${{ if eq(parameters['environment'], 'PR') }}
 YamlException: (Line: 14, Col: 7, Idx: 513) - (Line: 14, Col: 52, Idx: 558): Duplicate key

# TODO
- foreach expression
- extend template

# Reference/links
- https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops
