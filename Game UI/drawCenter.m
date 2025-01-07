function centerAxes = drawCenter(gameObj, centerAxes, hexSideLength)
%DRAWENVIRONMENT Summary of this function goes here
%   Detailed explanation goes here

cla(centerAxes);
for i = 1:length(gameObj.CenterTileIdx)
    centerX = i * 2 * hexSideLength;
    centerY = hexSideLength;

    % Draw Habitat Tile hexagon
    currentTile = gameObj.HabitatTiles(gameObj.CenterTileIdx(i));
    currentTile.Orientation = 1;
    drawHabitatTile(centerAxes, [centerX centerY], hexSideLength, currentTile, i);

    % Draw Wildlife Token circle
    centerY = -hexSideLength;
    shapeSize = 18;
    currentToken = gameObj.WildlifeTokens(gameObj.CenterTokenIdx(i));   
    drawWildlifeToken(centerAxes, [centerX, centerY], shapeSize, currentToken, i);
end

end