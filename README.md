# Pipelinespec

Create and maintain your pipelines like code and with tests :)

Currently it only supports Azure Pipelines.

## Pre-requisites

This module has a few dependencies:

- Install-Module Pester (to run the tests)
- Install-Module powershell-yaml (to load the pipeline)
- git (to fetch remote modules)

## Usage

- Define your `Pipeline.Tests.ps1` file in the same folder your pipeline is
- Run:

```shell
Invoke-Pester
```

or:

```shell
./Pipeline.Tests.ps1
```

## Development/testing

To avoid the need to reload your module after every change, if you are using bash/zsh/etc you can run this:
```
pwsh -Command "Invoke-Pester"
```

## Known bugs and limitations
- It doesn't validate if the mentioned dependsOn block exists;
- If you use the same key twice in the same context you'll get this error:
```
[-] Describe pipeline.yml failed
 ArgumentException: An item with the same key has already been added. Key: <key value>
 YamlException: (Line: 14, Col: 7, Idx: 513) - (Line: 14, Col: 52, Idx: 558): Duplicate key
```

## TODO
- Try to define automatically $Pipeline, $Stage, $Job and $Step variables inside each test context
- `foreach` expression;
- `else` expression;
- `extend` template.
