function Get-cTyBuildingList{
    Param()

    [ArrayList]$BuildingList = @()
    foreach($item in [cTyPS]::BuildingDict.Keys){
        $null = $BuildingList.Add([building]::new($item))
    }

    $BuildingList | 
        select -ExcludeProperty Level |
        select Name,Description,Cost,Type
        ft -AutoSize
}