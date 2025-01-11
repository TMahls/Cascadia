function scoreTable = calculateAllScores(gameObj)
%CALCULATEALLSCORES Summary of this function goes here
%   Detailed explanation goes here

scoreTable = gameObj.CurrentScores;

% Calculate wildlife scores
for i = 1:uint8(AnimalEnum.NumAnimals)
    currAnimal = AnimalEnum(i - 1);

    % Get which score card we're using
    if ~isscalar(gameObj.ScoringRules)
        scoreNum = gameObj.ScoringRules(uint8(currAnimal) + 1);
    else % Family or intermediate variant
        scoreNum = gameObj.ScoringRules;
    end
    className = gameObj.GameParameters.getScoringClassName(currAnimal, scoreNum);

    % We do this outside of the player loop to be efficient with our score
    % rule class creation-- reuse same class for all players.
    wildlifeScoreClass = feval(className);

    % Find table row containing that animal


    for j = 1:length(gameObj.Players)
        currPlayer = gameObj.Players(j);
        currEnv = currPlayer.Environment;

        % Calculate Score
        wildlifeScore = wildlifeScoreClass.calculateScore(currEnv);
    end
end

for i = 1:length(gameObj.Players)
    currPlayer = gameObj.Players(i);
    currEnv = currPlayer.Environment;

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