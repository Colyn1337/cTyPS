using namespace System.Collections
Param(
    [switch]$DevBuild
)
$Location = $PSScriptRoot
if([string]::IsNullOrEmpty($Location)){
  $Location = Get-Location
}
$Targets = "Class","Public","Private"
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
[string]$DefaultUsings = 
    "using namespace System.Collections" +
    [System.Environment]::NewLine

$Content += $DefaultUsings

$BuildList = [ordered]@{
    Enums = $Files | where basename -like "*enum*"
    Classes = $Files | where basename -like "*class*"
    Tables = $Files | where basename -like "*table*"
    Private = $Files | where {$_.directory.name -eq 'Private'}
    Public = $Files | where {$_.directory.name -eq 'Public'}
}
Foreach($key in $BuildList.Keys){
    $splGetContent = @{
        Path = $BuildList.$Key
        Raw = $true
        ErrorAction = 'SilentlyContinue'
    }
    $Content += Get-Content @splGetContent
    $Content += [System.Environment]::NewLine
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
    Name = 'cTyPS.psm1'
    Force = $True
    Value = $content
}
if($DevBuild){
    $splNewItem.Name = 'devcTyPS.psm1'
}
$null = New-Item @splNewItem

[string]$HelpContent = Get-Content $Location\en-US\about_cTyPS.help.txt -Raw
$splNewItem = @{
    Path = $Location
    ItemType = 'File'
    Name = 'README.md'
    Force = $True
    Value = $HelpContent
}
$null = New-Item @splNewItem
