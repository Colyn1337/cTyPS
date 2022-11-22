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
    [int]          $MaxJobs

    Building([string]$Name){
        if([cTyPS]::BuildingDict.$Name){
            $building = [cTyPS]::BuildingDict.$Name
            $this.Name = $Name
            $this.Cost = $building.BaseCost
            $this.Description = $building.Desc
            $this.Type = $building.Type
            if($building.MaxJobs){
              $this.MaxJobs = $building.MaxJobs
            }
        }else{
            throw "Building with the name $name does not exist in dictionary."
        }
    }

    Building([string]$Name,[int]$Level){
        if([cTyPS]::BuildingDict.$Name){
            $building = [cTyPS]::BuildingDict.$Name
            $this.Name  = $Name
            $this.Level = $Level
            $this.Cost = $building.BaseCost
            $this.Description = $building.Desc
            $this.Type = $building.Type
            if($building.MaxJobs){
              $this.MaxJobs = $building.MaxJobs
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
            15000 * ([int][Difficulty]::$Difficulty / 100)
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
        $Pops = $this.Population
        $jobs = $MaxJobs - $LaborPool

        if($jobs -ge ($LaborPool / 10)){
            Write-Verbose 'Jobs for anyone who wants one, or two, or three!'
            $Modifier = ([int][Difficulty]::$($this.Difficulty) / 100)
            $Change = [Math]::floor($Pops + (($jobs / 8) * $Modifier))

            $this.Population = $change
        }elseif($jobs -eq $LaborPool){ 
            Write-Verbose 'Somehow there is no change with jobs this month'
        }else{
            $this.Population = $Pops - 10
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
        #Typically 1/3 of a population is working age
        #Will become more complex as the game grows
        $LaborPool = [Math]::Floor($cty.Population / 3)
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