function scoreTable = calculateAllScores(gameObj)
%CALCULATEALLSCORES Summary of this function goes here
%   Detailed explanation goes here

scoreTable = gameObj.CurrentScores;

% Calculate scores for that row
for j = 1:length(gameObj.Players)

    % Calculate wildlife scores
    for i = 1:uint8(AnimalEnum.NumAnimals)
        currAnimal = AnimalEnum(i - 1);

        % Find table row containing that animal

        % Get which score cards we're using
        scoreClassName = gameObj.ScoringRules(uint8(currAnimal) + 1);



    end


    % Calculate habitat scores

    % Nature tokens

end

% Assign habitat bonuses

% Sum totals

end