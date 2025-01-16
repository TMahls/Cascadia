# Cascadia
Cascadia board game implemented in MATLAB.

This app was developed in R2025a but should work for previous releases,
at least back to 2020.

## Table of Contents

 1. [Getting Started](#getting-started) 
 2. [Folder Structure](#folder-structure)
 3. [Re-building Standalone Application](#re-building-app)
 3. [API Documentation](#api-documentation)


## Getting Started
Running the Cascadia App in MATLAB is simple:
1. Download or clone this repository
2. Open 'Cascadia.prj' in MATLAB
3. Click the 'CascadiaGUI' shortcut to launch the app
4. Enjoy!

If you just want to install the standalone app (no MATLAB required):

[TODO]

## Folder Structure
Explanation of folders / files in this repo.

### Autoplayer
The original goal of this project was to make a Cascadia AI, the GUI is 
just incidental. 'Autoplayer' is a subclass of 'Player'.

### Game Core
All core game files. I went with a class-based structure where each 'object'
in the game (Players, Environment, Wildlife Tokens, Habitat Tiles) has its own class.

There's not much use of subclassing but each class will generally have a property that is another class.
Game has property of Player array, which has Environment, which has Habitat Tile array, which has 
WildlifeToken. 
GameParameters is where I tried to keep all the hard-coded numbers and text for the game setup.
This includes tile distribution, token counts, etc.

'DualTerrainTileWildlife.xlsx' is a spreadsheet that gets read in by GameParameters to
determine compatible wildlife on dual-terrain tiles, since there doesn't seem to be as much
of a pattern with those-- but I still didn't want to manually hard-code every tile. 

#### Enums
I also make heavy use of Enums to keep the code readable but still allow numerical operations. 

Examples:
``` 
if(currTile.WildlifeToken.Animal == AnimalEnum.Bear)

'EdgeColor', ColorEnum.Gold.rgbValues

if (gameObj.GameMode == GameModeEnum.FamilyVariant || ...
                gameObj.GameMode == GameModeEnum.IntermediateVariant)

```

A couple of these enums start at 0 and have their end value be 'NumX', indicating 
how many members are in the Enum. I'm not sure if there's a better way to do this, 
but it definitely came in handy:

``` 
% Calculate wildlife scores
for i = 1:uint8(AnimalEnum.NumAnimals)
    currAnimal = AnimalEnum(i - 1); 
```

MovesEnum is the big one, where I made all the possible moves a static method:
```
% Perform 'Discard Token' move
app.CascadiaGame = playerAction(app.CascadiaGame, MovesEnum.DiscardToken, tokenIdx);
```

#### Scoring
All scoring files live here. Generally I try not to let any one file get over 300-400 lines, 
so I had to do some experimenting to see how many files I would need to capture all the rules
while keeping things organized.

I settled on a basic class structure-- all the rules are subclasses of 'WildlifeScoreObjective', 
which has utility methods common to multiple scoring rules such as 'calculateGroupSizes', 
'getAdjacentAnimals', etc. 

A couple methods in Environment and HabitatTile are also very important for scoring. Recursion was used in 
determining the size of a Habitat 'Corridor' or wildlife token group. 

### Game UI
All files relating to the UI live here. Each 'Window' of the app has its own
.mlapp file, so you can see there is one main app (CascadiaGUI) and 3 child dialogs
that can come up. To try and prevent messiness right now you can only have one dialog
window open at a time. 

There are also a couple utility MATLAB functions that start with 'draw' that actually
contain the plot commands-- for this I made use of [nsidedpoly](#https://www.mathworks.com/help/matlab/ref/nsidedpoly.html)
and [polyshape](#https://www.mathworks.com/help/matlab/ref/polyshape.html), which made drawing the basic tile and token
shapes very easy. These were introduced in R2017b, on an older version 'patch' would
probably be the function to use.  

## Re-building App
The build task is built into the project. To re-build the EXE after making 
edits to the code or app:
1. In the Project Tools menu, select 'Compiler Task Manager'
2. Open the existing 'StandaloneDesktopApp' task
3. Click 'Build and Package'
4. The updated EXE and installer will pop up in the 'Deployment' folder on your computer


## API Documentation
Documentation and examples for playing the game programatically.
This can be used to develop autoplayer algorithms. 

WARNING: Many of the internal properties and methods in 'Game Core' are 
not private or protected. Absolutley no attention was paid to security 
when I was writing this. You could very easily cheat by accessing these
internal functions, please adhere to the honor system! 

[TODO]

``` 
% Start game
obj = Game;
nPlayers = 3;
obj = obj.startNewGame(nPlayers);
```