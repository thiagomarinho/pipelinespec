function Fetch-Property {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $PropertyName,

        [Object]
        [Alias('Pipeline', 'Stage', 'Job', 'Step')]
        $Subject
    )

    if ($null -eq $Subject[$PropertyName]) {
        throw "Property ${PropertyName} not found on $($Subject._meta.Type) $($Subject._meta.Name)"
    }

    return $Subject[$PropertyName]
}
