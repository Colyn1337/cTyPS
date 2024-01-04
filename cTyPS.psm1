using namespace System.Collections
using namespace System.Management.Automation

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
    Agricultural
    Industrial
    Civic
}

Enum Crops{
    Sorghum
    Maize
    Wheat
    Sugarcane
}
class cTyPS {
    static $BuildingDict
}

Class Region : cTyPS {
    [string] $Name
    static [city[]] $CityList
}

Class Production : cTyPS {
    [int]       $Units
    [string]    $Name = 'None'

    Production(){
    }
}

class Building : cTyPS {
    [string]       $Name
    [BuildingType] $Type
    [int]          $Level
    [string]       $Description
    [int]          $Cost
    [int]          $MaxJobs
    [Production]   $Production = [Production]::new()

    Building([string]$Name,[int]$Level = 1){
        if([cTyPS]::BuildingDict.$Name){
            $building = [cTyPS]::BuildingDict.$Name
            $this.Name  = $Name
            $this.Level = $Level
            $this.Cost = $building.BaseCost
            $this.Description = $building.Desc
            $this.Type = $building.Type
            switch ($building) {
                {$_.MaxJobs -ne $null}{
                    'maxjobs triggered'
                    $this.MaxJobs = $building.MaxJobs}
                {$_.Production -ne $null}{
                    $this.Production.Units = 
                      $building.Production.Units
                    $this.Production.Name =
                      [crops].GetEnumValues()[0]
                }
            }
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
            100 * ([int][Difficulty]::$Difficulty / 100)
        $this.Cash =
            25000 * ([int][Difficulty]::$Difficulty / 100)
        $this.NewBuild(
            'Town Hall', 1
        )
        $this.Date =
            [datetime]::new($year,1,1).ToString("MMMM, yyyy")
    }

    [object]NextTurn(){
        $this.Date = ([datetime]$this.Date).AddMonths(1).ToString("MMMM, yyyy")
    
        $MaxJobs = [Economics]::CalculateMaxEmployment($this.Name)
        $LaborPool = [Economics]::LaborPool($this.Name)
        $Modifier = [Economics]::Modifier($this.name)
        $Pops = $this.Population
        $OpenJobs = $MaxJobs - $LaborPool

        if($OpenJobs -ge ($LaborPool / 3)){
            Write-Verbose 'Jobs for anyone who wants one, or two, or three!'
            $Change = [Math]::Ceiling($Pops + (($OpenJobs / 8) * $Modifier))

            $this.Population = $Change
        }elseif($OpenJobs -gt $LaborPool){
            Write-Verbose 'Employment is growing'
            $Change = $Pops + 1
            $this.population = $Change
        }elseif($OpenJobs -eq $LaborPool){ 
            Write-Verbose 'Somehow you have achieved that prefect employment balance'
        }else{
            $this.Population = $Pops - 1
        }
        
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

    static [int] Modifier( [string]$cTy ){
        $ctyobj = [region]::CityList | where name -eq $cTy
        $Modifier = ([int][Difficulty]::$($ctyobj.Difficulty) / 100)
        return $Modifier
    }

    static [int] CalculateTax( [string]$Class,[int]$Population ){
        return $Population * [Economics]::Taxes.$Class
    }

    static [int] CalculateMaxEmployment( [string]$cTy ){
        $ctyobj = [region]::CityList | where name -eq $cTy
        $Buildings = $ctyobj.Buildings
        #Powershell 7.3 doesn't include the sum method on int arrays
        #Further, measure-object can only calc the count of an array, not
        #the mathematical functions like average, sum, etc.  Oldschool it is
        $count = 0
        foreach($int in $Buildings.MaxJobs){$count += $int}
        return $count
    }

    static [int] LaborPool( [string]$cTy ){
        $ctyobj = [region]::CityList | where name -eq $cTy
        #Typically 1/3 of a population is working age however this causes
        #the city to ramp up too quickly/unrealistically. Using 2/3
        #till more logic comes into play later.
        $LaborPool = [Math]::Ceiling(($ctyobj.Population / 3 * 2))
        return $LaborPool
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
<#
  Buildings are organized by Type, then by class with Districts
  listed first.
#>

[cTyPs]::BuildingDict = @{
    'Government District' = @{
        Class     = [BuildingClass]::District
        Type      = [BuildingType]::Civic
        Desc      = 'Land set aside for government structures and use.'
        BaseCost  = 10000
    }
    'Town Hall' = @{
        Class     = [BuildingClass]::Building
        Type      = [BuildingType]::Civic
        Desc      = 'Provides governance and collects taxes.'
        BaseCost  = 12000
        MaxJobs   = 50
        DependsOn = @{
            'Government District' = 1
        }
    }
    'Residential District' = @{
        Class     = [BuildingClass]::District
        Type      = [BuildingType]::Residential
        Desc      = 'Zoned space for apartments, condos, and dwellings.'
        BaseCost  = 15000
        BasePop   = 3000
    }
    'Housing Subdivision' = @{
        Class     = [BuildingClass]::Building
        Type      = [BuildingType]::Residential
        Desc      = 'A small community of standalone houses.'
        BaseCost  = 1000
        BasePop   = 75
    }
    'Simple Apartments' = @{
        Class     = [BuildingClass]::Building
        Type      = [BuildingType]::Residential
        Desc      = 'A space sprawling with Apartment buildings.'
        BaseCost  = 6000
        BasePop   = 250
        DependsOn = @{
            'Residential District' = 2
        }
    }
    'Sprawling Apartment Complex' = @{
        Class     = [BuildingClass]::Building
        Type      = [BuildingType]::Residential
        Desc      = 'Rows of multistory buildings for apartment dwelers.'
        BaseCost  = 25000
        BasePop   = 550
        DependsOn = @{
            'Residential District' = 4
        }
    }
    'Founders Statue' = @{
        Class     = [BuildingClass]::Monument
        Type      = [BuildingType]::Civic
        Desc      = 'A monument to commemorate the founding of the city.'
        BaseCost  = 0
    }
    'Agricultural District' = @{
        Class    = [BuildingClass]::District
        Type     = [BuildingType]::Agricultural
        Desc     = 'Land dedicated for food stuffs production.'
        BaseCost = 5000
        MaxJobs  = 0
    }
    'Basic Farms' = @{
        Class    = [BuildingClass]::Building
        Type     = [BuildingType]::Agricultural
        Desc     = 'The lowest producing farm type you can build.'
        BaseCost = 1000
        MaxJobs  = 100
        DependsOn = @{
            'Agricultural District' = 1
        }
        Production = @{
            Options = [Crops]
            Units   = 1
        }
    }
    'Profit Farms' = @{
        Class    = [BuildingClass]::Building
        Type     = [BuildingType]::Agricultural
        Desc     = 'The lowest producing farm type you can build.'
        BaseCost = 4000
        MaxJobs  = 200
        DependsOn = @{
            'Agricultural District' = 1
        }
        Production = @{
            Options = [Crops]
            Units   = 5
        }
    }
    'Industrial District' = @{
        Class    = [BuildingClass]::District
        Type     = [BuildingType]::Industrial
        Desc     = 'Low value land designated for industry.'
        BaseCost = 7000
        MaxJobs  = 0
    }
    'Box Factory' = @{
        Class    = [BuildingClass]::Building
        Type     = [BuildingType]::Industrial
        Desc     = "Box shaped factory producing, well, boxes."
        BaseCost = 2000
        MaxJobs  = 100
        DependsOn = @{
            'Industrial District' = 1
        }
    }
    'Commercial District' = @{
        Class    = [BuildingClass]::District
        Type     = [BuildingType]::Commercial
        Desc     = 'A space for businesses and offices.'
        BaseCost = 25000
        MaxJobs  = 0
    }
}
Function Get-cTyBuildingDict {
    [ctyps]::BuildingDict
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
Function Get-EconomicModel{
    [Economics]::new()
}
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
  Author:  Colyn Via
  Contact:   colyn.via@protonmail.com
  Version:   1.0.0
  Date:    11.26.2022
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
function Get-cTyBuildOrderList{
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
}
function New-cTy{
<#
#>
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

    Get-Cty $Name
}

Function New-cTyBuildOrder{
<#
  .SYNOPSIS
    For adding buildings to a cTy.
  .DESCRIPTION
    Adds a new building to the cTy if the requirements are met and
    the cTy has enough dough for construction. The Building param
    will cycle through all Building options.
  .EXAMPLE
    New-cTyBuilding -cTy MycTy -Building 'Founders Statue'
  .OUTPUTS
    Boolean
  .NOTES
    Author:    Colyn Via
    Contact:   colyn.via@protonmail.com
    Version:   1.0.0
    Date:      11.22.2022
#>
    [cmdletbinding()]
    Param (
        [validateset([cTyCities])]
        [string]$cTy = [region]::CityList[0].Name,

        [ValidateSet([cTyBuildingNames])]
        [string]$Construction
    )

    $cTyObj = Get-cTyObject $cTy
    $cTyBuilding = [cTyPS]::BuildingDict.$Construction
    $Build = $true

    $Dependency = $cTyBuilding.DependsOn
    if($Dependency){
        $existing = $cTyObj.Buildings
        foreach($key in $Dependency.keys){
            if($existing.name -eq $key -and 
               $existing.level -ge $Dependency[$key]){
            }else{
                $Build = $false
                Write-Error "$Construction requires $key" +
                  " level $($Dependency[$key])"
            }
        }
    }

    if($cTyObj.Cash -lt $cTyBuilding.BaseCost){
        Write-Error "Not enough dough in $cTy coffers to build $Construction!"
        $Build = $false
    }

    if($Build){
        $cTyObj.NewBuild($Construction, 1)
        $ctyObj.Cash = $cTyObj.Cash - [int]$cTyBuilding.BaseCost
    }
    return $build
}

Function Next-cTyTurn {
    [cmdletbinding()]
    Param(
        [validateset([cTyCities])]
        [string[]]$Name = [region]::CityList[0].Name,

        [validaterange(1,12)]
        [int]$Count = 1
    )

    $VerbosePreference = "Continue"
    foreach($cTy in $Name){
        $cTyObj = Get-cTyObject $cTy
        for($x=1;$x -le $count;$x++){
            $null = $cTyObj.NextTurn()
        }
    }
}
$ExportList = @('Get-cTy',
'Get-cTyBuildOrderList',
'New-cTy',
'New-cTyBuildOrder',
'Next-cTyTurn')
    Export-ModuleMember $ExportList