Import-Module powershell-yaml

#Get public and private function definition files.
#$Classes = @( Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue )
$Classes = @(
    "$PSScriptRoot\Classes\TemplateLoader.Class.ps1",
    "$PSScriptRoot\Classes\Expression.Class.ps1",
    "$PSScriptRoot\Classes\PipelineLoader.Class.ps1"
)

$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue -Recurse )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse )

#Dot source the files
Foreach($import in @($Classes)) {
    Try
    {
        Write-Verbose -Message "Loading $($import)"
        . $import
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Foreach($import in @($Public + $Private)) {
    Try
    {
        Write-Verbose -Message "Loading $($import.fullname)"
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Set-Alias -Name Pipeline -Value Describe
Set-Alias -Name Stage -Value Context
Set-Alias -Name Job -Value Context
Set-Alias -Name Step -Value Context

Export-ModuleMember -Alias Pipeline
Export-ModuleMember -Alias Stage
Export-ModuleMember -Alias Job
Export-ModuleMember -Alias Step

Export-ModuleMember -Function $Public.Basename