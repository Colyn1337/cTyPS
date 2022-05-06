using module ./cTyEnums.psm1
using module ./cTyClasses.psm1

[cTyPs]::BuildingDict = @{
    'Residential District' = @{
        Class = [BuildingClass]::District
        Type = [BuildingType]::Residential
        Desc = 'Zoned space for apartments, condos, and dwellings.'
        BaseCost = 15000
        BasePop = 3000
    }
    'Government District' = @{
        Class = [BuildingClass]::District
        Type = [BuildingType]::Civic
        Desc = 'Land set aside for government structures and use.'
        BaseCost = 10000
    }
    'Town Hall' = @{
        Class = [BuildingClass]::Building
        Type = [BuildingType]::Civic
        Desc = 'Provides governance and collects taxes.'
        BaseCost = 12000
    }
    'Apartment Complex' = @{
        Class = [BuildingClass]::Building
        Type = [BuildingType]::Residential
        Desc = 'A space sprawling with Apartment buildings..'
        BaseCost = 6000
        BasePop = 2500
    }
    'Founders Statue' = @{
        Class = [BuildingClass]::Monument
    }
}