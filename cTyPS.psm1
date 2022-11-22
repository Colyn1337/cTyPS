using namespace System.ComponentModel.DataAnnotations;

Enum Difficulty{
    Easy    = 125
    Medium  = 100
    Hard    = 75
}

Enum BuildingClass{
    District
    Building
    Monument
}

Enum BuildingType{
    Residential
    Commercial
    Industrial
    Civic
}

<#Powershell doesn't seem to like/support enum attributes
Add-Type -TypeDefinition @"
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
public enum BuildingName
{
    [Display(Name="Town Hall")]
    TownHall,
    [Display(Name="Residential District")]
    ResidentialDistrict
}
"@
#>
#using module ./cTyEnums.ps1
#using module ./cTyTables.ps1 Don't uncomment or it will cause a load loop: 'module nesting limit'

class cTyPS {
    static $BuildingDict
}

Class Region : cTyPS {
    [string] $Name
    static [city[]] $CityList
}

class Building : cTyPS {
    [string]       $Name
    [BuildingType] $Type
    [int]          $Level
    [string]       $Description
    [int]          $Cost

    Building([string]$Name){
        if([cTyPS]::BuildingDict.$Name){
            $this.Name = $Name
            $this.Cost = [cTyPS]::BuildingDict.$Name.BaseCost
            $this.Description = [cTyPS]::BuildingDict.$Name.Desc
            $this.Type = [cTyPS]::BuildingDict.$Name.Type
        }else{
            throw "Building with the name $name does not exist in dictionary."
        }
    }

    Building([string]$Name,[int]$Level){
        if([cTyPS]::BuildingDict.$Name){
            $this.Name  = $Name
            $this.Level = $Level
            $this.Cost = [cTyPS]::BuildingDict.$Name.BaseCost
            $this.Description = [cTyPS]::BuildingDict.$Name.Desc
            $this.Type = [cTyPS]::BuildingDict.$Name.Type
        }else{
            throw "Building with the name $name does not exist in dictionary."
        }
    }
}

Class City : cTyPS{
    [String]     $Name
    [int]        $Population
    [int]        $Cash
    [string]     $Difficulty
    [Building[]] $Buildings
    [string]     $Date

    City([Difficulty]$Difficulty, [string]$Name, [int]$Year){
        $this.Name = $Name
        $this.Difficulty = $Difficulty
        $this.Population = 
            10000 * ([int][Difficulty]::$Difficulty / 100)
        $this.Cash =
            75000 * ([int][Difficulty]::$Difficulty / 100)
        $this.NewBuild(
            'Town Hall', 1
        )
        $this.Date =
            [datetime]::new($year,1,1).ToString("MMMM, yyyy")
    }

    [object]NextTurn(){
        $this.Date = ([datetime]$this.Date).AddMonths(1).ToString("MMMM, yyyy")
        $this.Cash += [Economics]::CalculateTax('Residential',$this.Population)
        return $this
    }

    [void]NewBuild($Name, $Level){
        $this.Buildings +=
            ([Building]::new($Name,$Level))
    }
}

Class Economics : cTyPS{
    static $Taxes = @{
        Residential = 0.05
        Commercial  = 0.05
        Industrial  = 0.05
    }

    Economics(){
    }

    static [int] CalculateTax( [string]$Class,[int]$Population ){
        return $Population * [Economics]::Taxes.$Class
    }
}

Class cTyBuildingNames : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $BuildingNames = [cTyPS]::BuildingDict.Keys
        return [String[]] $BuildingNames
    }
}

Class cTyCities : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $cTyNames = [region]::CityList.Name
        return [String[]] $cTyNames
    }
}
#using module ./cTyEnums.ps1
#using module ./cTyClasses.ps1

<#
  Buildings are organized by Type, then by class with Districts
  listed first.
#>

[cTyPs]::BuildingDict = @{
    'Government District' = @{
        Class    = [BuildingClass]::District
        Type     = [BuildingType]::Civic
        Desc     = 'Land set aside for government structures and use.'
        BaseCost = 10000
    }
    'Town Hall' = @{
        Class    = [BuildingClass]::Building
        Type     = [BuildingType]::Civic
        Desc     = 'Provides governance and collects taxes.'
        BaseCost = 12000
    }
    'Residential District' = @{
        Class    = [BuildingClass]::District
        Type     = [BuildingType]::Residential
        Desc     = 'Zoned space for apartments, condos, and dwellings.'
        BaseCost = 15000
        BasePop  = 3000
    }
    'Apartment Complex' = @{
        Class    = [BuildingClass]::Building
        Type     = [BuildingType]::Residential
        Desc     = 'A space sprawling with Apartment buildings.'
        BaseCost = 6000
        BasePop  = 2500
    }
    'Founders Statue' = @{
        Class    = [BuildingClass]::Monument
        Type     = [BuildingType]::Civic
        Desc     = 'A monument to commemorate the founding of the city.'
        BaseCost = 0
    }
    'Industrial District' = @{
        Class    = [BuildingClass]::District
        Type     = [BuildingType]::Industrial
        Desc     = 'Low value land designated for industry.'
        BaseCost = 7000
        BaseEmp  = 0
    }
    'Commercial District' = @{
        Class    = [BuildingClass]::District
        Type     = [BuildingType]::Commercial
        Desc     = 'A space for businesses and offices.'
        BaseCost = 25000
        BaseEmp  = 0
    }
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
} function Get-cTyBuildingList{
  Param(
    [BuildingType]$Type
  )

  [ArrayList]$ReturnList = @()

  $BuildingList = [cTyPS]::BuildingDict

  foreach($item in $BuildingList.Keys){
    if($Type -and $BuildingList[$item].Type -eq $Type){
      $null = $ReturnList.Add([building]::new($item))
    }elseif(! $Type){
      $null = $ReturnList.Add([building]::new($item))
    }
  }

  $ReturnList | 
    select -ExcludeProperty Level |
    select Name,Description,Cost,Type
    ft -AutoSize
} function New-cTy{
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
} function Show-Cty{
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
$ExportList = @('Get-cTy',
'Get-cTyBuildingList',
'New-cTy',
'New-cTyBuilding',
'Next-cTyTurn',
'Show-cTy')
Export-ModuleMember $ExportList