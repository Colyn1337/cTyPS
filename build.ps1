<#
  .SYNOPSIS
    A universal build script for pwsh and Powershell projects.

  .DESCRIPTION
    Compiles individual code files into a module file for
    distribution. Loads files and orders them based on named
    purpose (e.g. enum, class, private, public).

  .EXAMPLE
    Build a module project for distribution.

    ./build.ps1

  .EXAMPLE
    Build a developer version of the module project for testing

    ./build.ps1 -DevBuild

  .NOTES

    Author:       Colyn Via
    Contact:      colyn.via@protonmail.com
    Updated:      09.26.2023
    Version:      1.0.30

    Contributors:
                  None
#>
using namespace System.Collections
[cmdletbinding()]
Param(
    [switch]$DevBuild
)
$Location = $PSScriptRoot
if([string]::IsNullOrEmpty($Location)){
  $Location = Get-Location
}
$ModuleName = (Get-Item $Location).Name

$Targets = "Enum","Class","Classes","Public","Private"
[ArrayList]$Files = $null

Foreach($Target in $Targets){
    $splFiles = @{
        Path = "$Location\$target"
        File = $true
        Recurse = $true
        Include = "*.ps1"
        Exclude = "build.ps1"
        ErrorAction = 'SilentlyContinue'
    }
    $Files += Get-ChildItem @splFiles
}

[string]$Content = $null
[string[]]$DefaultUsings = @(
    "System.Collections",
    "System.Management.Automation"
)
if($DefaultUsings){
    foreach($item in $DefaultUsings){
        $content += 'using namespace ' + $item + [System.Environment]::NewLine
    }
    $Content += [System.Environment]::NewLine
}

$BuildList = [ordered]@{
    Enums = $Files | where basename -like "*enum*"
    Classes = $Files | where basename -like "*class*"
    Tables = $Files | where basename -like "*table*"
    Private = $Files | where {$_.directory.name -eq 'Private'}
    Public = $Files | where {$_.directory.name -eq 'Public'}
}
Foreach($key in $BuildList.Keys){
    $items = $BuildList.$key
    foreach($item in $items){
        $splGetContent = @{
            Path = $item
            Raw = $true
            ErrorAction = 'SilentlyContinue'
        }
        $result = 'Failed!'
        $Content += Get-Content @splGetContent
        $Content += [System.Environment]::NewLine
        if($?){$result = 'Success!'}
        Write-Verbose "$item... $result"
    }
}

If(! $DevBuild){
    [string]$ExportList = @(
        foreach($PublicCmdlet in $BuildList.Public.BaseName){
            [string]$cmdName = $PublicCmdlet
            "'" + $cmdName + "'"
        }
    )
    $ExportList = $ExportList -replace " ",",`n"

    $ModuleExport = '$ExportList = @(' + $ExportList + ')' +'
    Export-ModuleMember $ExportList'

    $Content += $ModuleExport
}

$splNewItem = @{
    Path = $Location
    ItemType = 'File'
    Name = "$ModuleName.psm1"
    Force = $True
    Value = $content
}
if($DevBuild){
    $splNewItem.Name = "dev_" + $ModuleName + ".psm1"
    $msg = "Dev build of $ModuleName initated. Creating file: " +
           $splNewItem.Name
    
    $was = $InformationPreference
    $InformationPreference = 'Continue'
    Write-Information $msg
    $InformationPreference = $was
}
$null = New-Item @splNewItem

$HelpFilePath = "$Location\en-US\about_" + $ModuleName + ".help.txt"
[string]$HelpContent = Get-Content $HelpFilePath -Raw -EA SilentlyContinue
if(! $?){
    Write-Verbose 'No module helpfile found.'
}

$splNewItem = @{
    Path = $Location
    ItemType = 'File'
    Name = 'README.md'
    Force = $True
    Value = $HelpContent
    EA = 'silentlycontinue'
}
$null = New-Item @splNewItem
if(! $?){
    Write-Verbose 'Copy of module help to readme.md failed.'
}