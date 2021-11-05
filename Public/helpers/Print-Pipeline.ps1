Function Print-Pipeline {
    [CmdletBinding()]
    param (
        [object]
        $Pipeline
    )

    Write-Host "Printing simplified pipeline"
    Write-Host ($Pipeline | ConvertTo-Yaml) | Out-String

    foreach ($Stage in $Pipeline['stages']) {
        Write-Host "$($Stage.stage) (stage)" -ForegroundColor Yellow

        foreach ($Job in $Stage['jobs']) {
            Write-Host "  $($Job.job) (job)" -ForegroundColor Blue
        }
    }
}