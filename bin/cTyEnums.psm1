using namespace System.ComponentModel.DataAnnotations;

Enum Difficulty{
    Easy    = 125
    Medium  = 100
    Hard    = 75
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