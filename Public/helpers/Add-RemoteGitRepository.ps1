function Add-RemoteGitRepository {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $ResourceName,

        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $Url
    )

    Safe-CreateDir "./fixtures" 

    if (Test-Path "./fixtures/${ResourceName}") {
        if (Test-Path "./fixtures/${ResourceName}/.git") {
            git -C "./fixtures/${ResourceName}" pull
        } else {
            Write-Warning "Resource ${ResourceName} already exists at ./fixtures/${$ResourceName} and it's not a git repository"
        }
    } else {
        git clone $Url  "./fixtures/${ResourceName}"
    }
}
