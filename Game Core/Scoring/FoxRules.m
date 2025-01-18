classdef FoxRules < WildlifeScoreObjective

    properties

    end

    methods
        function obj = FoxRules()
            obj.Animal = AnimalEnum.Fox;
        end

        function groupScore = ruleAShape(obj, environment, groupCoords)
            groupScore = 0;
            for i = 1:size(groupCoords,1) % For each fox in the group
                tile = tileAtCoords(environment, groupCoords(i,:));

                neighborAnimals = getAdjacentAnimals(obj, environment, tile);

                groupScore = groupScore + nnz(neighborAnimals);
            end
        end

        function groupScore = ruleBShape(obj, environment, groupCoords)
            groupScore = 0;
            for i = 1:size(groupCoords,1) % For each fox in the group
                tile = tileAtCoords(environment, groupCoords(i,:));

                neighborAnimals = getAdjacentAnimals(obj, environment, tile);

                pairIdx = (neighborAnimals >= 2); % Number of pairs
                % Choosing to count trios/larger groups as 1 unique pair

                % Remove fox pairs
                pairIdx(obj.Animal + 1) = 0;

                if any(pairIdx)
                    groupScore = groupScore + (2 * nnz(pairIdx) + 1);
                end
            end
        end

        function groupScore = ruleCShape(obj, environment, groupCoords)
            groupScore = 0;
            for i = 1:size(groupCoords,1) % For each fox in the group
                tile = tileAtCoords(environment, groupCoords(i,:));

                neighborAnimals = getAdjacentAnimals(obj, environment, tile);
                neighborAnimals(obj.Animal + 1) = 0; % Don't include foxes in count

                maxAnimals = max(neighborAnimals);
                groupScore = groupScore + maxAnimals;
            end
        end

        function groupScore = ruleDShape(obj, environment, groupCoords)
            % This one has complicated edge-cases. Luckily, it's been
            % answered by Randy! https://boardgamegeek.com/thread/2817617/fox-card-d-rule-clarification
            % Since you are meant to take the best fox pairs, this can be
            % scored similarly to Elk A,B,D.

            shapes = GroupShape([0,0,0; 1,0,-1],0);
            groupScore = recursiveGetBestShapeFit(obj, groupCoords, environment, shapes);
        end

    end

    methods (Access = protected)
        function largestScore = recursiveGetBestShapeFit(obj, groupCoords, environment, shapes)
            % Gets the highest score for an arrangement of shapes within a
            % group. Overloaded from parent class to tweak scoring of
            % groups for Fox D

            largestScore = 0;

            for i = 1:size(groupCoords,1) % For each tile in group

                currCoords = groupCoords(i,:);

                shapeList = getShapesThatStartWith(obj, currCoords, groupCoords, shapes);

                % Only one valid shape so no trimming necessary

                for j = 1:length(shapeList) % For each shape that starts with that tile
                    currShape = shapeList(j);
                    subGroupCoords = groupCoords;

                    % Remove shape coords from coord list
                    shapeCoords = currShape.Coordinates;
                    [~, groupCoordsIdx] = ismember(shapeCoords, groupCoords, 'rows');
                    subGroupCoords(groupCoordsIdx,:) = [];

                    % Calculate score for fox pair
                    pairScore = foxDSinglePairScore(obj, environment, shapeCoords);

                    % Add shape score to current score, recurse with
                    % sub-group
                    score = pairScore + recursiveGetBestShapeFit(obj, subGroupCoords, environment, shapes);

                    if score > largestScore
                        largestScore = score;
                    end
                end
            end
        end

        function pairScore = foxDSinglePairScore(obj, environment, pairCoords)
            % Given an environment and coordinates for a fox pair,
            % calculate the rule D score for that pair

            % Get pair neighbors
            neighborsA = HabitatTile.getNeighborCoordinates(pairCoords(1,:));
            neighborsB = HabitatTile.getNeighborCoordinates(pairCoords(2,:));

            pairNeighbors = unique([neighborsA; neighborsB], "rows");
            animalsFound = zeros(1, AnimalEnum.NumAnimals);

            % This is similar to WildlifeScoreObjective.getAdjacentAnimals
            % but needs to run on an arbitrary set of 'neighbors'
            for i = 1:size(pairNeighbors,1)
                neighborTile = tileAtCoords(environment, pairNeighbors(i,:));
                neighborAnimal = neighborTile.WildlifeToken.Animal;
                if ~isempty(neighborAnimal)
                    animalsFound(neighborAnimal + 1) = ...
                        animalsFound(neighborAnimal + 1) + 1;
                end
            end

            % Now we score similar to Fox B
            pairIdx = (animalsFound >= 2); % Number of pairs
            % Choosing to count trios/larger groups as 1 unique pair

            % Remove fox pairs
            pairIdx(obj.Animal + 1) = 0;

            if any(pairIdx)
                pairScore = 2 * nnz(pairIdx) + 3;
            end
        end
    end



end