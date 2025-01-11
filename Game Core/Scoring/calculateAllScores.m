function scoreTable = calculateAllScores(gameObj)
%CALCULATEALLSCORES Summary of this function goes here
%   Detailed explanation goes here

scoreTable = gameObj.CurrentScores;

for i = 1:length(gameObj.Players)
    currPlayer = gameObj.Players(i);
    currEnv = currPlayer.Environment;

    % Calculate wildlife scores
    for j = 1:uint8(AnimalEnum.NumAnimals)
        currAnimal = AnimalEnum(j - 1);

        % Find table row containing that animal

        % Get which score card we're using
        scoreNum = gameObj.ScoringRules(uint8(currAnimal) + 1);
        className = gameObj.GameParameters.getScoringClassName(currAnimal, scoreNum)


    end

    % Calculate habitat scores
    for j = 1:uint8(TerrainEnum.NumTerrains)
        
        nTiles = largestCorridorSize(currEnv, TerrainEnum(j));

    end

    % Nature tokens
    currPlayer.NatureTokens;

end

% Assign habitat bonuses
if gameObj.HabitatBonus


end

% Sum totals

end