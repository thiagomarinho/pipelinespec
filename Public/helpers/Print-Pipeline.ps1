Function Print-Pipeline {
    [CmdletBinding()]
    param (
        [object]
        $Pipeline,

        [switch]
        $Details = $false
    )

    if ($Details) {
        Write-Host "Printing simplified pipeline"
        Write-Host (($Pipeline | ConvertTo-Yaml) | Out-String) -ForegroundColor Green
        Write-Host "---"
    }

    foreach ($Stage in $Pipeline['stages']) {
        $StageDescription = "$($Stage.stage) (stage)"

        if ($Stage.dependsOn) {
            $StageDescription += " [dependsOn $($Stage.dependsOn)]"
        }

        Write-Host $StageDescription -ForegroundColor Yellow

        foreach ($Job in $Stage['jobs']) {
            $JobDescription = "  $($Job.job) (job)"

            if ($Job.dependsOn) {
                $JobDescription += " [dependsOn $($Job.dependsOn)]"
            }

            Write-Host $JobDescription -ForegroundColor Blue
        }
    }
}