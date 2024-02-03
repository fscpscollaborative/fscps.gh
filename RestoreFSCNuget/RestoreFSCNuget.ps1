Param(
    [Parameter(HelpMessage = "DynamicsVersion", Mandatory = $true)]
    [string] $DynamicsVersion
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0
# IMPORTANT: No code that can fail should be outside the try/catch

try {
    $helperPath = Join-Path -Path $PSScriptRoot -ChildPath "..\FSC-PS-Helper.ps1" -Resolve
    . $helperPath

    installModules @("AZ.Storage")

    Write-Output "::group::Download default NuGet packages"
    OutputInfo "======================================== Download default NuGet"

    Update-FSCNuGet -sdkVersion $DynamicsVersion
    Write-Output "::endgroup::"

    Write-Output "::group::Nuget install packages"
    OutputInfo "======================================== Nuget install packages"

    GeneratePackagesConfig -DynamicsVersion $DynamicsVersion
    nuget restore -PackagesDirectory ..\NuGets
    Write-Output "::endgroup::"
}
catch {
  OutputError -message $_.Exception.Message
}
finally
{
  OutputInfo "Execution is done."
}