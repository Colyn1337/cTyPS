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
}