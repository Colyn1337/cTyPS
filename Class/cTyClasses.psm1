using module ./cTyEnums.psm1
#using module ./cTyTables.psm1 Don't uncomment or it will cause a load loop: 'module nesting limit'

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