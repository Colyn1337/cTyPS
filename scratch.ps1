return


$splPSDrive = @{
    Name = 'cTy'
    PSProvider = 'Environment'
    Root = ''
}
$null = New-PSDrive @splPSDrive

[Hashtable]$Global:ctyBuildingDictionary = @{
    'Town Hall' = @{
        Desc = 'Provides governance and collects taxes.'
        BaseCost = 12000}
    'Housing Complex' = @{
        Desc = ''
        BaseCost = 15000
        BasePop = 3000
    }
}