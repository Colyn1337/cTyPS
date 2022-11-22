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

    Show-Cty $Name
}
