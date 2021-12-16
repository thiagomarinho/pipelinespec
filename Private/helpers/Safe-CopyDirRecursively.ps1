function Safe-CopyDirRecursively {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $SourceDirectory,

        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $TargetDirectory
    )

    if (!(Test-Path $SourceDirectory)) {
        Write-Warning "Directory ${SourceDirectory} not found"
    } else {
        if (Test-Path $TargetDirectory) {
            Write-Warning "Directory ${TargetDirectory} already exists. Skipping"
        } else {
            Copy-Item $SourceDirectory -Destination $TargetDirectory -Recurse
        }
    }
}
