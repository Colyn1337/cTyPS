Function New-cTyBuilding{
    [cmdletbinding()]
    Param (
        [validateset([cTyCities])]
        [string]$cTy,

        [ValidateSet([cTyBuildingNames])]
        [string]$Building
    )

    $cTyObj = Get-cTyObject $cTy
    $cTyBuilding = [cTyPS]::BuildingDict.$Building

    if($cTyObj.Cash -ge $cTyBuilding.BaseCost){
        $cTyObj.NewBuild($Building, 1)
        $ctyObj.Cash = $cTyObj.Cash - [int]$cTyBuilding.BaseCost
    }else{
        Write-Error "Not enough dough in $cTy coffers to build $Building!"
    }

    return $true
}
