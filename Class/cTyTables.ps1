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
    'Industrial District' = @{
        Class    = [BuildingClass]::District
        Type     = [BuildingType]::Industrial
        Desc     = 'Low value land designated for industry.'
        BaseCost = 7000
        BaseEmp  = 0
    }
    'Box Factory' = @{
        Class    = [BuildingClass]::Building
        Type     = [BuildingType]::Industrial
        Desc     = "Box shaped factory producing, well, boxes."
        BaseCost = 2000
        BaseEmp  = 100
        DependsOn = @{
            'Industrial District' = 1
        }
    }
    'Commercial District' = @{
        Class    = [BuildingClass]::District
        Type     = [BuildingType]::Commercial
        Desc     = 'A space for businesses and offices.'
        BaseCost = 25000
        BaseEmp  = 0
    }
}