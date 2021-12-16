function Get-Pipeline {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $Filename
    )

    return [PipelineLoader]::new($Filename).Load()
}
