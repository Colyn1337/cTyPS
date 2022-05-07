$Location = $PSScriptRoot
if([string]::IsNullOrEmpty($Location)){
  $Location = Get-Location
}

$splFiles = @{
  Path = $Location
  File = $true
  Recurse = $true
  Include = "*.ps1"
  Exclude = "build.psm1","build.ps1"
}
$Files = Get-ChildItem @splFiles

foreach($file in $Files){
  . $File.FullName
}