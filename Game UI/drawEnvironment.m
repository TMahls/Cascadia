function envAxes = drawEnvironment(environment, envAxes, playerId)
%DRAWENVIRONMENT Summary of this function goes here
%   Detailed explanation goes here

cla(envAxes);

envAxes.Title.String = sprintf('Player %.0f''s Environment', playerId);


sideLength = 0.5;
% Draw Starter habitat tile
for i = 1:length(environment.StarterHabitatTile)
    currentTile = environment.StarterHabitatTile(i);
    [centerX, centerY] = HabitatTile.hex2cart(currentTile.Coordinate, sideLength);
    drawHabitatTile(envAxes, centerX, centerY, sideLength, currentTile, 0);
end

% Draw other tiles
for i = 1:length(environment.HabitatTiles)
    currentTile = environment.HabitatTiles(i);
    [centerX, centerY] = HabitatTile.hex2cart(currentTile.Coordinate, sideLength);
    drawHabitatTile(envAxes, centerX, centerY, sideLength, currentTile, 0);
end

end