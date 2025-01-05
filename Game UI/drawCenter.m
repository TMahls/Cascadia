function centerAxes = drawCenter(gameObj, centerAxes)
%DRAWENVIRONMENT Summary of this function goes here
%   Detailed explanation goes here

cla(centerAxes);
for i = 1:length(gameObj.CenterTileIdx)
    centerX = i;
    centerY = 1;
    shapeSize = 0.25;

    % Draw Habitat Tile hexagon
    currentTile = gameObj.HabitatTiles(gameObj.CenterTileIdx(i));    
    drawHabitatTile(centerAxes, centerX, centerY, shapeSize, currentTile)

    % Draw Wildlife Token circle
    centerY = -1;
    shapeSize = 100;
    currentToken = gameObj.WildlifeTokens(gameObj.CenterTokenIdx(i));   
    drawWildlifeToken(centerAxes, centerX, centerY, shapeSize, currentToken)
end

end