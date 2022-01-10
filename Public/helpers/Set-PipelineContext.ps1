function Set-PipelineContext {
    Write-Host 'Set PipelineContext'
    $Global:__PipelineContext = @{
        Parameters = @{};
        Variables = @{};
    }
}
