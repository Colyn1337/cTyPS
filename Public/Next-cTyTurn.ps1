Function Next-cTyTurn {
<#
#>
    [cmdletbinding()]
    Param(
        [validateset([cTyCities])]
        [string[]]$Name = [region]::CityList[0].Name,

        [validaterange(1,12)]
        [int]$Count = 1
    )

    $oldPref = $VerbosePreference
    $VerbosePreference = "Continue"
    foreach($cTy in $Name){
        $cTyObj = Get-cTyObject $cTy
        for($x=1;$x -le $count;$x++){
            $null = $cTyObj.NextTurn()
        }
    }
    $VerbosePreference = $oldPref
}