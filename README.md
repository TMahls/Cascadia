# Cascadia
Cascadia board game implemented in MATLAB.

This app was developed in R2025a but should work for previous releases,
at least back to 2020.

## Table of Contents

 1. [Getting Started](#getting-started) 
 2. [Folder Structure](#folder-structure)
 3. [Re-building Standalone Application](#rebuilding-app)
 3. [API Documentation](#api-documentation)


## Getting Started
Running the Cascadia App in MATLAB is simple:
1. Download or clone this repository
2. Open 'Cascadia.prj' in MATLAB
3. Click the 'CascadiaGUI' shortcut to launch the app
4. Enjoy!

If you just want to download the EXE:
[TODO]

## Folder Structure
Explanation of folders / files in this repo.


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