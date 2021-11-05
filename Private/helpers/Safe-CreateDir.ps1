function Safe-CreateDir {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Directory
    )

    if (!(Test-Path $Directory)) {
        New-Item $Directory -ItemType "Directory"
    } else {
        Write-Information "Directory ${Directory} already exists"
    }
}
