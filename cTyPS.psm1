using namespace System.Collections
using module ./bin/cTyEnums.psm1 
using module ./bin/cTyClasses.psm1
using module ./bin/cTyTables.psm1

function New-cTy{
    Param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Difficulty] $Difficulty = 'Medium',
        [int] $Year = [datetime]::Now.Year
    )

    if([Region]::CityList.Name -contains $Name){
        $string = "A cTy already exists with the name $Name. " + `
        "Use Show-cTy instead."
        Write-Error $string -EA Stop
    }

    [region]::CityList += 
        [City]::new($Difficulty,$Name,$Year)

    Show-Cty $Name
}

function Get-cTyObject{
    Param(
        [validateset([cTyCities])]
        [string] $Name
    )

    if($Name){
        $cTy = [region]::CityList | where name -eq $Name
    }else{
        $cTy = [region]::CityList
    }

    if(-not $cTy){
        Write-Error "No cTy found with the name: $Name" -EA Stop
    }

    $cTy
}

function Show-Cty{
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
}

function Get-cTyBuildingList{
    Param()

    [ArrayList]$BuildingList = @()
    foreach($item in [cTyPS]::BuildingDict.Keys){
        $null = $BuildingList.Add([building]::new($item))
    }

    $BuildingList | 
        select -ExcludeProperty Level |
        select Name,Description,Cost,Type
        ft -AutoSize
}

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

Function Next-cTyTurn {
    Param(
        [validateset([cTyCities])]
        [string[]]$Name = [region]::CityList[0].Name,

        [validaterange(1,12)]
        [int]$Count = 1
    )

    foreach($cTy in $Name){
        $cTyObj = Get-cTyObject $cTy
        for($x=1;$x -le $count;$x++){
            $null = $cTyObj.NextTurn()
        }
    }
}