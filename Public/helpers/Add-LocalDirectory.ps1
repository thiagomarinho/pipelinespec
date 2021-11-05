function Add-LocalDirectory {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [String]
        $Directory
    )

    Safe-CreateDir "./fixtures" 
    Safe-CopyDirRecursively -SourceDirectory $Directory -TargetDirectory "./fixtures/${ResourceName}"
}
