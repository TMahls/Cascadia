function scoreTable = calculateAllScores(gameObj)
%CALCULATEALLSCORES Summary of this function goes here
%   Detailed explanation goes here

scoreTable = gameObj.CurrentScores;

familyVariant = isscalar(gameObj.ScoringRules) && ...
    gameObj.ScoringRules == GameModeEnum.FamilyVariant;

intermediateVariant = isscalar(gameObj.ScoringRules) && ...
    gameObj.ScoringRules == GameModeEnum.IntermediateVariant;

for i = 1:length(gameObj.Players)
    currPlayer = gameObj.Players(i);
    currEnv = currPlayer.Environment;

    % Calculate wildlife scores
    for j = 1:uint8(AnimalEnum.NumAnimals)
        currAnimal = AnimalEnum(j - 1);

        % Find table row containing that animal

        % Get which score card we're using
        if ~isscalar(gameObj.ScoringRules)
            scoreNum = gameObj.ScoringRules(uint8(currAnimal) + 1);
        else % Family or intermediate variant
            scoreNum = gameObj.ScoringRules;
        end
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