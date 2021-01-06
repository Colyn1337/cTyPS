using module ./bin/cTyEnums.psm1 
using module ./bin/cTyClasses.psm1
using module ./bin/cTyTables.psm1

function New-cTy{
    Param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Difficulty] $Difficulty = 'Medium',
        [int] $Year = 2020
    )

    [region]::CityList += 
        [City]::new($Difficulty,$Name,$Year)

    [region]::CityList | where name -eq $Name
}

function Get-cTy{
    Param(
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
        [parameter(mandatory=$true)]
        #[ValidateSet({[region]::CityList.Name})]
        [string]$Name
    )

    $cTy = Get-cTy $Name

    'cTy DETAILS:'
    $cTy | select * -ExcludeProperty Buildings | ft 

    "BUILDING LIST:"
    $cTy.Buildings | ft 
}

Function New-cTyBuilding{
    [cmdletbinding()]
    Param (
        [ValidateSet({$Global:ctyBuildingDictionary.Keys})]
        [string]$Name
    )
}