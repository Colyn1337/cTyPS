using namespace System.Collections
using module ./Class/cTyEnums.psm1 
using module ./Class/cTyClasses.psm1
using module ./Class/cTyTables.psm1

$Location = $PSScriptRoot
if([string]::IsNullOrEmpty($Location)){
  $Location = Get-Location
}

$splFiles = @{
  Path = $Location
  File = $true
  Recurse = $true
  Include = "build.ps1"
}
$Files = Get-ChildItem @splFiles

foreach($file in $Files){
  . $File.FullName
}