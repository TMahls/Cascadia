function envAxes = drawEnvironment(environment, envAxes, playerObj, hexSideLength)
%DRAWENVIRONMENT Summary of this function goes here
%   Detailed explanation goes here

cla(envAxes);

envAxes.Title.String = sprintf('%s Environment', playerObj.Name);

allTiles = [environment.StarterHabitatTile, environment.HabitatTiles];
for i = 1:length(allTiles)
    currentTile = allTiles(i);
    centerCoords = HabitatTile.hex2cart(currentTile.Coordinate, hexSideLength);
    drawHabitatTile(envAxes, centerCoords, hexSideLength, currentTile, 0);
end

% Draw preview tile or token
currentTile = environment.PreviewTile;
if ~isempty(currentTile) && isPlaceableTileCoord(environment, currentTile.Coordinate)
    centerCoords = HabitatTile.hex2cart(currentTile.Coordinate, hexSideLength);
    drawHabitatTile(envAxes, centerCoords, hexSideLength, currentTile, -1);
elseif ~isempty(currentTile) && ~isempty(environment.PreviewToken) &&...
        isPlaceableTokenCoord(environment, currentTile.Coordinate) && playerObj.TilePlaced 
    wildlifeToken = environment.PreviewToken;
    centerCoords = HabitatTile.hex2cart(currentTile.Coordinate, hexSideLength);
    drawWildlifeToken(envAxes, centerCoords, hexSideLength, wildlifeToken, -1)
end

axis(envAxes,'equal'); % Prevents stretching

end