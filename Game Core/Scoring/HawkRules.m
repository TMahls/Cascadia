classdef HawkRules < WildlifeScoreObjective

    properties

    end

    methods
        function obj = HawkRules()
            obj.Animal = AnimalEnum.Hawk;
        end

        function score = ruleAScore(obj, environment)
            scoreTable = [2 5 8 11 14 18 22 26];
            hawkTiles = getAllAnimalTiles(obj, environment, obj.Animal);
            loneHawkCount = 0;

            for i = 1:length(hawkTiles)
                currTile = hawkTiles(i);
                neighborAnimals = getAdjacentAnimals(obj, environment, currTile);

                if ~neighborAnimals(obj.Animal + 1)
                    loneHawkCount = loneHawkCount + 1;
                end
            end

            score = pointsForAttribute(obj, scoreTable, loneHawkCount);
        end

        function score = ruleBScore(obj, environment)
            scoreTable = [0 5 9 12 16 20 24 28];
            hawkTiles = getAllAnimalTiles(obj, environment, obj.Animal);
            loneHawkCount = 0;

            for i = 1:length(hawkTiles)
                currTile = hawkTiles(i);
                neighborAnimals = getAdjacentAnimals(obj, environment, currTile);

                hasLOS = hasLineOfSight(obj, currTile, environment);

                if ~neighborAnimals(obj.Animal + 1) && hasLOS
                    loneHawkCount = loneHawkCount + 1;
                end
            end

            score = pointsForAttribute(obj, scoreTable, loneHawkCount);
        end

        function score = ruleCScore(obj, environment)
            score = 0;
            hawkTiles = getAllAnimalTiles(obj, environment, obj.Animal);
            for i = 1:length(hawkTiles)
                currTile = hawkTiles(i);
                [~, losCoords] = hasLineOfSight(obj, currTile, environment);
                NLos = length(losCoords);
                score = score + 3 * NLos;
            end
            score = score / 2; % We will have double-counted
        end

        function score = ruleDScore(obj, environment)
            % This one is also tricky since each hawk can only be in 1
            % pair. Must choose interpretation that maximizes points.

            hawkTiles = getAllAnimalTiles(obj, environment, obj.Animal);
            score = recursiveGetBestLOSCombo(obj, environment, hawkTiles);
        end
    end

    methods(Access = private)
        function [tf, losCoords] = hasLineOfSight(obj, tile, env)
            % Determines whether a particular hawk in an environment has
            % line of sight with another hawk, and the coordinates of all
            % lines of sight that it has.
            % lostCoords is a cell array, where eacn entry contains ALL
            % coords in the line of sight, not just end points.

            % Check in increasing radius -- until when? Until all tiles are
            % empty.

            tf = false;
            losCoords = {};

            emptyRing = false; N = 2; idx = 1;
            while ~emptyRing % If all ring coords empty, we're done.
                % Get ring coords
                ringCoords = getRingCoords(obj,N);
                ringCoordsAdjusted = tile.Coordinate + int8(ringCoords);

                emptyRing = true;
                for i = 1:size(ringCoords,1)
                    isLosTile = any(ringCoords(i,:) == 0);

                    currTile = tileAtCoords(env, ringCoordsAdjusted(i,:));

                    if ~isempty(currTile.Terrain)
                        emptyRing = false;
                    end

                    if isLosTile && ~isempty(currTile.WildlifeToken.Animal) && ...
                            currTile.WildlifeToken.Animal == obj.Animal
                        % Line of sight to hawk spotted - check in-between for
                        % blocks by other hawks

                        coordsBetween = zeros(N+1,3);
                        direction = int8(ringCoords(i,:)./N); % Direction vector
                        blockingHawk = false;
                        for n = 1:(N-1)
                            coordsBetween(n+1,:) = tile.Coordinate + n.*direction;
                            testTile = tileAtCoords(env,  coordsBetween(n+1,:));
                            if ~isempty(testTile.WildlifeToken.Animal) && ...
                                    (testTile.WildlifeToken.Animal == obj.Animal)
                                blockingHawk = true;
                            end
                        end

                        coordsBetween(1,:) = tile.Coordinate;
                        coordsBetween(end,:) = currTile.Coordinate;

                        if ~blockingHawk % True LOS found!
                            tf = true;
                            losCoords{idx} = coordsBetween;
                            idx = idx + 1;
                        end
                    end
                end

                N = N + 1; % Increase distance
            end
        end

        function ringCoords = getRingCoords(~,N)
            % Get coordinates N dist away from the origin
            ringCoords = zeros(6*N,3);
            idx = 1;
            for a = -N:N
                if abs(a) == N
                    for b = 0:(-1*sign(a)):-a
                        ringCoords(idx,:) = [a, b, 0 - a - b];
                        idx = idx + 1;
                    end
                else % 2 pairs of coords
                    if a >= 0
                        b1 = -N;
                        b2 = -a + N;
                    else
                        b1 = N;
                        b2 = -a - N;
                    end
                    ringCoords(idx,:) = [a, b1, 0 - a - b1];
                    ringCoords(idx + 1,:) = [a, b2, 0 - a - b2];
                    idx = idx + 2;
                end
            end
        end

        function largestScore = recursiveGetBestLOSCombo(obj, env, hawkTiles)

            largestScore = 0; scoreTable = [4 7 9];
            for i = 1:length(hawkTiles) % For each hawk tile in group

                currTile = hawkTiles(i);
                [~, losCoords] = hasLineOfSight(obj, currTile, env);

                for j = 1:length(losCoords)
                    % Pair up with a hawk it has LOS with 
                    currLOS = losCoords{j};

                    % Remove those hawks from coord list and environment
                    hawkSubGroup = hawkTiles; k = 1;
                    while k <= length(hawkSubGroup)
                        testTile = hawkSubGroup(k);
                        if all(testTile.Coordinate == currLOS(1,:)) || ...
                                all(testTile.Coordinate == currLOS(end,:))
                            hawkSubGroup(k) = [];
                            allTilesIdx = getTileIdx(env, testTile);

                            if allTilesIdx > length(env.StarterHabitatTile)
                                idx = allTilesIdx - length(env.StarterHabitatTile);
                                env.HabitatTiles(idx).WildlifeToken = WildlifeToken();
                            else
                                env.StarterHabitatTile(idx).WildlifeToken = WildlifeTRoken();
                            end
                        else
                            k = k + 1;
                        end
                    end                 
                    
                    % Calculate number of unique animals in LOS
                    % Array of whether we have found a particular animal
                    animalsFound = zeros(1, AnimalEnum.NumAnimals);

                    for k = 2:(size(currLOS,1) - 1)
                        losTile = tileAtCoords(env, currLOS(k,:));
                        losAnimal = losTile.WildlifeToken.Animal;
                        if ~isempty(losAnimal)
                            animalsFound(losAnimal + 1) = ...
                                animalsFound(losAnimal + 1) + 1;
                        end
                    end
                    animalsFound(obj.Animal + 1) = 0; % Exclude other hawks

                    currLOSScore = pointsForAttribute(obj, scoreTable, nnz(animalsFound));

                    % Add hawk pair score to current score, recurse with
                    % sub-group
                    score =  currLOSScore + ...
                        recursiveGetBestLOSCombo(obj, env, hawkSubGroup);

                    if score > largestScore
                        largestScore = score;
                    end
                end
            end
        end

    end
end

