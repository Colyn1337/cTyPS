function Get-cTy{
<#
.SYNOPSIS
  For displaying cTy details.

.DESCRIPTION
  Acts as the primary UI for the game. Presents information
  in various groupings to facilitate easy decision making and
  exploration of the game.

.EXAMPLE
  Get-cTy

  Returns information on the first/default cTy

.EXAMPLE
  Get-cTy secondville

  Returns cTy details on the specified cTy.

.NOTES
  Author:    Colyn Via
  Contact:   colyn.via@protonmail.com
  Version:   1.3.0
  Initial:   11.26.2022
  Updated:   01.04.2024
  
#>
  Param(
    [ValidateSet([cTyCities])]
    [string]$Name = [region]::CityList[0].Name
  )

  $cTy = Get-cTyObject $Name

  $cTy | select -ExcludeProperty Buildings | ft 

  "INFRASTRUCTURE:"
  $cTy.Buildings | 
    select -ExcludeProperty Cost |
    select Name,Description,Level,Type
    ft -AutoSize

  "`nPRODUCTION:"
  $prod = $cTy.Buildings | where {$_.Production.Name -ne 'None'}
  if($prod){
    $pList = @()
    foreach($item in $prod.Production){
      for($x=1; $x -le $item.Units; $x++){
        $pList += $item.Name
      }
    }
    $pList | 
      Group-Object |
      Select Name,Count |
      ft -AutoSize
  }else{
    "`nNothing, maybe we should build something!`n"
  }
  
  'COMMANDS:'
  'Next-cTyTurn Get-cTyBuildOrderList New-cTyBuildOrder'
  ''
}