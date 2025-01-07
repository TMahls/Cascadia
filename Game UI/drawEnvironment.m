function envAxes = drawEnvironment(environment, envAxes, playerId, hexSideLength)
%DRAWENVIRONMENT Summary of this function goes here
%   Detailed explanation goes here

cla(envAxes);

envAxes.Title.String = sprintf('Player %.0f''s Environment', playerId);

allTiles = [environment.StarterHabitatTile, environment.HabitatTiles];
for i = 1:length(allTiles)
    currentTile = allTiles(i);
    centerCoords = HabitatTile.hex2cart(currentTile.Coordinate, hexSideLength);
    drawHabitatTile(envAxes, centerCoords, hexSideLength, currentTile, 0);
end

% Draw preview tile
currentTile = environment.PreviewTile;
if ~isempty(currentTile)
    centerCoords = HabitatTile.hex2cart(currentTile.Coordinate, hexSideLength);
    drawHabitatTile(envAxes, centerCoords, hexSideLength, currentTile, -1);
end
end