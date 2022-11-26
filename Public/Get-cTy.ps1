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
    Version:   1.0.0
    Date:      11.26.2022
#>
    Param(
        [ValidateSet([cTyCities])]
        [string]$Name = [region]::CityList[0].Name
    )

    $cTy = Get-cTyObject $Name

    $cTy | select -ExcludeProperty Buildings | ft 

    "BUILDING LIST:"
    $cTy.Buildings | 
        select -ExcludeProperty Cost | 
        select Name,Description,Level,Type
        ft -AutoSize 

    "`nCOMMANDS:"
    "Next-cTyTurn Get-cTyBuildingList New-cTyBuilding"
}