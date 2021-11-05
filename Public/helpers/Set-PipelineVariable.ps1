function Set-PipelineVariable {
    param (
        [string]
        $Name,

        [string]
        $Value
    )

    $Global:__PipelineContext.Variables[$Name] = $Value
}