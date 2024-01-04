function Get-cTyBuildOrderList{
  Param(
    [BuildingType]$Type
  )

  [ArrayList]$ReturnList = @()

  $BuildingList = [cTyPS]::BuildingDict

  foreach($item in $BuildingList.Keys){
    if($Type -and $BuildingList[$item].Type -eq $Type){
      $null = $ReturnList.Add([building]::new($item))
    }elseif(! $Type){
      $null = $ReturnList.Add([building]::new($item))
    }
  }
  
  $ReturnList | 
    select -ExcludeProperty Level |
    select Name,Description,Cost,Type
    ft -AutoSize
}