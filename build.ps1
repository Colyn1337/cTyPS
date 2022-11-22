using namespace System.Collections

$Location = $PSScriptRoot
if([string]::IsNullOrEmpty($Location)){
  $Location = Get-Location
}
$Targets = "Class","Public","Private"
[ArrayList]$Files = $null
[string]$Content = $null

Foreach($Target in $Targets){
    $splFiles = @{
        Path = "$Location\$target"
        File = $true
        Recurse = $true
        Include = "*.ps1","*.psm1"
        Exclude = "build.psm1","build.ps1","buildtest.ps1"
        ErrorAction = 'SilentlyContinue'
    }
    $Files += Get-ChildItem @splFiles
}

$BuildList = @{
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

$splNewItem = @{
    Path = $Location
    ItemType = File
    Name = 'cTyPS.psm1'
    Force = $True
    Value = $content
}
New-Item @splNewItem
