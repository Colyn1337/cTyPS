Function New-cTyBuilding{
    [cmdletbinding()]
    Param (
        [validateset([cTyCities])]
        [string]$cTy = [region]::CityList[0].Name,

        [ValidateSet([cTyBuildingNames])]
        [string]$Building
    )

    $cTyObj = Get-cTyObject $cTy
    $cTyBuilding = [cTyPS]::BuildingDict.$Building
    $Build = $true

    $Dependency = $cTyBuilding.DependsOn
    if($Dependency){
        $existing = $cTyObj.Buildings
        foreach($key in $Dependency.keys){
            if($existing.name -eq $key -and 
               $existing.level -ge $Dependency[$key]){
            }else{
                $Build = $false
                Write-Error "$Building requires $key level $($Dependency[$key])"
            }
        }
    }

    if($cTyObj.Cash -lt $cTyBuilding.BaseCost){
        Write-Error "Not enough dough in $cTy coffers to build $Building!"
        $Build = $false
    }

    if($Build){
        $cTyObj.NewBuild($Building, 1)
        $ctyObj.Cash = $cTyObj.Cash - [int]$cTyBuilding.BaseCost
    }
    return $build
}
