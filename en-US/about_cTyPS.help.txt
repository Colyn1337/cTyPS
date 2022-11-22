TOPIC
    about_cTyPS

SHORT DESCRIPTION
    cTyPS is a prototype text based city builder game written entirely in pwsh (Powershell).

LONG DESCRIPTION
    Originating from a natural love of strategy and city builder games I use this project is 
    used to test concepts in pwsh.  Shortcuts such as using C# code to overcome pwsh's 
    limitations are not permitted by design.

HOW TO PLAY

    Use the New-Cty cmdlet to create a new city.

    PS> New-cTy -Name 'MycTy'

    At anytime you can pull the current status of your city. If you've created more than one
    cTy, the Name parameter will autocomplete with their names to cycle through. The default
    is the first created cTy and only one cTy is displayed per call.

    PS> Get-cTy
    PS> Get-cTy -Name secondville

    Turns in cTyPS are counted in months. The Next-cTyTurn cmdlet will advance your game to
    the next turn. The game will default to the first cTy created if no name is provided.

    PS> Next-cTyTurn

    You can alternatively advance multiple cTy's at once by specifying their names. As with
    the Get-cTy cmdlet, autocomplete works here as well.

    PS> Next-cTyTurn -Name MycTy, secondville

    To view a list of buildings to create you can call the Get-cTyBuildingList cmdlet. Use
    the Type Parameter to filter the list based on the type of building you're interested
    in creating.

    PS> Get-cTyBuildingList
    PS> Get-cTyBuildingList -Type Civic

    Create new buildings with the New-cTyBuilding cmdlet one cTy at a time. The Building 
    parameter will autocomplete with the list of constructable buildings.

    PS> New-cTyBuilding -cTy MycTy -Building 'Town Hall'

KEYWORDS
    Terms or titles on which you might expect your users to search for the information in this topic.

SEE ALSO
    cTyPS github project https://github.com/Colyn1337/cTyPS