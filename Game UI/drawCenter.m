function centerAxes = drawCenter(gameObj, centerAxes)
%DRAWENVIRONMENT Summary of this function goes here
%   Detailed explanation goes here

cla(centerAxes);
for i = 1:length(gameObj.CenterTileIdx)
    centerX = i;
    centerY = 1;
    size = 0.25;

    % Draw Habitat Tile hexagon
    currentTile = gameObj.HabitatTiles(gameObj.CenterTileIdx(i));
    
    drawHabitatTile(centerAxes, centerX, centerY, size, currentTile)

    % Draw Wildlife Token circle
    size = 100;
    currentToken = gameObj.WildlifeTokens(gameObj.CenterTokenIdx(i));
    
    centerY = -1;
    drawWildlifeToken(centerAxes, centerX, centerY, size, currentToken)
end

end