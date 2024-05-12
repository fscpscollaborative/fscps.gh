Param(
    [Parameter(HelpMessage = "DynamicsVersion", Mandatory = $true)]
    [string] $DynamicsVersion,
    [Parameter(HelpMessage = "PackagesDirectory", Mandatory = $true)]
    [string] $PackagesDirectory
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0
# IMPORTANT: No code that can fail should be outside the try/catch

try {
    $helperPath = Join-Path -Path $PSScriptRoot -ChildPath "..\FSC-PS-Helper.ps1" -Resolve
    . $helperPath

    installModules @("fscps.tools")

    OutputInfo "======================================== Gather version info"
    $versionData = Get-FSCPSVersionInfo -Version $DynamicsVersion
    $PlatformVersion = $versionData.data.PlatformVersion
    $ApplicationVersion = $versionData.data.AppVersion

    OutputInfo "======================================== Download NuGet packages"
    if (-not (Test-Path $PackagesDirectory)) {
        New-Item -ItemType Directory -Force -Path $PackagesDirectory
    }
    $null = Get-FSCPSNuget -Version $PlatformVersion -Type PlatformCompilerPackage -Path $PackagesDirectory
    $null = Get-FSCPSNuget -Version $PlatformVersion -Type PlatformDevALM -Path $PackagesDirectory
    $null = Get-FSCPSNuget -Version $ApplicationVersion -Type ApplicationDevALM -Path $PackagesDirectory
    $null = Get-FSCPSNuget -Version $ApplicationVersion -Type ApplicationSuiteDevALM -Path $PackagesDirectory

    OutputInfo "======================================== Nuget install packages"
    GeneratePackagesConfig -DynamicsVersion $DynamicsVersion 
    Set-Location NewBuild
    nuget restore -PackagesDirectory $PackagesDirectory
    Write-Output "::endgroup::"
}
catch {
  OutputError -message $_.Exception.Message
}
finally
{
  OutputInfo "Execution is done."
}