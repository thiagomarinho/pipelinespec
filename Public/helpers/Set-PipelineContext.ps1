function Set-PipelineContext {
    Write-Debug 'Setting PipelineContext'

    $Global:__PipelineContext = @{
        Parameters = @{};
        Variables = @{};
    }
}
