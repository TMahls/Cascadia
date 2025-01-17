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
    [className, methodName] = gameObj.GameParameters.getScoringClassName(currAnimal, scoreNum);

    % We do this outside of the player loop to be efficient with our score
    % rule class creation-- reuse same class for all players.
    wildlifeScoreClass = feval(className);

    % Find table row containing that animal
    animalRow = findRowThatContains(scoreTable,char(currAnimal));

    for j = 1:length(gameObj.Players)
        currPlayer = gameObj.Players(j);
        currEnv = currPlayer.Environment;

        % Calculate Score
        if (gameObj.GameMode == GameModeEnum.FamilyVariant || ...
                gameObj.GameMode == GameModeEnum.IntermediateVariant)
            wildlifeScore = feval(methodName, wildlifeScoreClass, currEnv, currAnimal);
        else
            wildlifeScore = feval(methodName, wildlifeScoreClass, currEnv);
        end

        scoreTable(animalRow,j) = {wildlifeScore};
    end
end

natureTokenRow = findRowThatContains(scoreTable,'Nature Tokens');
for i = 1:length(gameObj.Players)
    currPlayer = gameObj.Players(i);
    currEnv = currPlayer.Environment;

    % Calculate habitat scores
    for j = 1:uint8(TerrainEnum.NumTerrains)
        currHabitat = TerrainEnum(j - 1);

        nTiles = largestCorridorSize(currEnv, currHabitat);

        habitatRow = findRowThatContains(scoreTable,...
            ['Largest ' char(currHabitat)]);

        scoreTable(habitatRow,i) = {nTiles};
    end

    % Nature tokens
    natureTokenPoints = gameObj.GameParameters.PointsPerNatureToken * currPlayer.NatureTokens;
    scoreTable(natureTokenRow, i) = {natureTokenPoints};
end

% Assign habitat bonuses
if gameObj.HabitatBonus
    % Calculate habitat scores
    for j = 1:uint8(TerrainEnum.NumTerrains)
        currHabitat = TerrainEnum(j - 1);
        habitatBonusRow = findRowThatContains(scoreTable,...
            [char(currHabitat) ' Bonus']);

        habitatRow = findRowThatContains(scoreTable,...
            ['Largest ' char(currHabitat)]);

        scoreTable(habitatBonusRow,:) = calculateBonuses(scoreTable(habitatRow,:));
    end
end

% Sum totals
wildlifeTotalRow = findRowThatContains(scoreTable, 'Wildlife Total');
scoreTable(wildlifeTotalRow,:) = sum(scoreTable(1:(wildlifeTotalRow-1),:),1);

habitatTotalRow = findRowThatContains(scoreTable, 'Habitat Total');
scoreTable(habitatTotalRow,:) = sum(scoreTable((wildlifeTotalRow+1):(habitatTotalRow-1),:),1);

% Assume grand total row is at the end
scoreTable(end,:) = sum(scoreTable([wildlifeTotalRow, habitatTotalRow, natureTokenRow],:),1);
end

function rowNum = findRowThatContains(table, searchChars)
rowNum = find(contains(table.Row, searchChars), 1);
if isempty(rowNum)
    error('Could not find row ''%s'' in score table!\n', searchChars);
end
end

function bonuses = calculateBonuses(habitatRow)
% This is where we define the bonus behavior
% There are some interesting edge-cases related to ties that are not
% necessarily intuitive.
nPlayers = width(habitatRow);
bonusArr = zeros(1,nPlayers);
bonuses = num2cell(bonusArr);

switch nPlayers
    case 1 % Solo game
        bonuses = (habitatRow >= 7) .* 2;
    case {2,3,4}
        rowArray = table2array(habitatRow);
        [sortedRow,indexRow] = sort(rowArray,'descend');

        % Calculate number of ties for first
        nTies = nnz(sortedRow == sortedRow(1)) - 1;
        secondLargest = sortedRow(find(sortedRow ~= sortedRow(1),1));

        switch nPlayers
            case 2
                pointsAwarded = 2 / (nTies + 1);
            otherwise
                switch nTies
                    case 0
                        pointsAwarded = 3;
                        % Points for 2nd largest
                        if nnz(sortedRow == secondLargest) == 1
                            bonusArr(indexRow(sortedRow == secondLargest)) = 1;
                        end
                    case 1
                        pointsAwarded = 2;
                    otherwise
                        pointsAwarded = 1;
                end
        end
        bonusArr(indexRow(sortedRow == sortedRow(1))) = pointsAwarded;
        bonuses = num2cell(bonusArr);
end
end