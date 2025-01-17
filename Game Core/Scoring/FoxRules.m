classdef FoxRules < WildlifeScoreObjective

    properties

    end

    methods
        function obj = FoxRules()
            obj.Animal = AnimalEnum.Fox;
        end

        function score = ruleAScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'foxAShape');
        end

        function score = ruleBScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'foxBShape');
        end

        function score = ruleCScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'foxCShape');
        end

        function score = ruleDScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'foxDShape');
        end

        function groupScore = foxAShape(obj, environment, groupCoords)
            groupScore = 0;
            for i = 1:size(groupCoords,1) % For each fox in the group
                tile = tileAtCoords(environment, groupCoords(i,:));

                neighborAnimals = getAdjacentAnimals(obj, environment, tile);

                groupScore = groupScore + nnz(neighborAnimals);
            end
        end

        function groupScore = foxBShape(obj, environment, groupCoords)
            groupScore = 0;
            for i = 1:size(groupCoords,1) % For each fox in the group
                tile = tileAtCoords(environment, groupCoords(i,:));

                neighborAnimals = getAdjacentAnimals(obj, environment, tile);

                pairIdx = (neighborAnimals == 2); % Number of pairs 
                
                % Remove fox pairs 
                pairIdx(obj.Animal + 1) = 0;

                if any(neighborAnimals == 2)
                    groupScore = groupScore + (2 * nnz(pairIdx) + 1);
                end
            end
        end

        function groupScore = foxCShape(obj, environment, groupCoords)
            groupScore = 0;
            for i = 1:size(groupCoords,1) % For each fox in the group
                tile = tileAtCoords(environment, groupCoords(i,:));

                neighborAnimals = getAdjacentAnimals(obj, environment, tile);
                [maxAnimals, idx] = max(neighborAnimals);
                if idx ~= (obj.Animal + 1) % Don't include foxes
                    groupScore = groupScore + maxAnimals;
                end
            end
        end

        function groupScore = foxDShape(obj, environment, groupCoords)
            % This one has complicated edge-cases. Luckily, it's been
            % answered by Randy! https://boardgamegeek.com/thread/2817617/fox-card-d-rule-clarification
            groupScore = 0;

        end
    end

end

