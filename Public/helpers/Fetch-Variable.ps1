# Subject or Context?

# Get-Variable already exists :/
# TODO change to Get-PipelineVariable
function Fetch-Variable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $VariableName,

        [Parameter(Mandatory = $true)]
        [Object]
        [Alias('Pipeline', 'Stage', 'Job', 'Step')]
        $Subject
    )

    if ($null -eq $Subject['variables'] -or ($null -eq $Subject['variables'][$VariableName])) {
        throw "Variable ${VariableName} not found on $($Subject._meta.Type) $($Subject._meta.Name)"
    }

    return $Subject['variables'][$VariableName]
}
