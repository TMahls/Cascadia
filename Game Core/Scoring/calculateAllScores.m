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
    animalRow = findRowThatContains(scoreTable,char(currAnimal));

    for j = 1:length(gameObj.Players)
        currPlayer = gameObj.Players(j);
        currEnv = currPlayer.Environment;

        % Calculate Score
        wildlifeScore = wildlifeScoreClass.calculateScore(currEnv);

        scoreTable(animalRow,j) = {wildlifeScore};
    end
end

for i = 1:length(gameObj.Players)
    currPlayer = gameObj.Players(i);
    currEnv = currPlayer.Environment;

    % Calculate habitat scores
    for j = 1:uint8(TerrainEnum.NumTerrains)
        currHabitat = TerrainEnum(j - 1);

        nTiles = largestCorridorSize(currEnv, currHabitat);

        habitatRow = findRowThatContains(scoreTable,...
            ['Connected ' char(currHabitat)]);

        scoreTable(habitatRow,i) = {nTiles};
    end

    % Nature tokens
    natureTokenPoints = gameObj.GameParameters.PointsPerNatureToken * currPlayer.NatureTokens;
    natureTokenRow = findRowThatContains(scoreTable,'Nature Tokens');
    scoreTable(natureTokenRow, i) = {natureTokenPoints};
end

% Assign habitat bonuses
if gameObj.HabitatBonus
    % Calculate habitat scores
    for j = 1:uint8(TerrainEnum.NumTerrains)
        currHabitat = TerrainEnum(j - 1);
        habitatBonusRow = findRowThatContains(scoreTable,...
            [char(currHabitat) ' Bonus']);

        % Use sort idx of habitat row perhaps. 

    end
end

% Sum totals

end

function rowNum = findRowThatContains(table, searchChars)
   rowNum = find(cellfun(@(x) contains(x,searchChars), table.Row), 1);
   if isempty(rowNum)
        error('Could not find row ''%s'' in score table!\n', searchChars);
   end
end