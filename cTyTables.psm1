using module ./cTyEnums.psm1
using module ./cTyClasses.psm1

[cTyPs]::BuildingDict = @{
    'Town Hall' = @{
        Type = [BuildingType]::Civic
        Desc = 'Provides governance and collects taxes.'
        BaseCost = 12000}
    'Residential District' = @{
        Type = [BuildingType]::Residential
        Desc = 'Zoned space for apartments, condos, and dwellings.'
        BaseCost = 15000
        BasePop = 3000
    }
}