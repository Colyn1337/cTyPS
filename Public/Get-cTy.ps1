function Get-cTy{
    Param(
        [ValidateSet([cTyCities])]
        [string]$Name = [region]::CityList[0].Name
    )

    $cTy = Get-cTyObject $Name

    'cTy DETAILS:'
    $cTy | select -ExcludeProperty Buildings | ft 

    "BUILDING LIST:"
    $cTy.Buildings | 
        select -ExcludeProperty Cost | 
        select Name,Description,Level,Type
        ft -AutoSize

    $VerbosePreference = 'continue'
    Write-Verbose 'Next-cTyTurn Get-cTyBuildingList New-cTyBuilding'
}