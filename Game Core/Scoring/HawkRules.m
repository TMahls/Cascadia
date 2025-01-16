classdef HawkRules < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = HawkRules()
            % Need common methods for 'not adjacent' and hasLineOfSights, with Returning Line of sight coords. 

        end

        function score = ruleAScore(obj, environment)
            score = 0;
            scoreArray = [2 5 8 11 14 18 22 26];
            hawkTiles = getAllAnimalTiles(obj, environment, AnimalEnum.Hawk);
            loneHawkCount = 0;

            for i = 1:length(hawkTiles)
                currTile = hawkTiles(i);
                neighborAnimals = getAdjacentAnimals(obj, environment, currTile);

                if ~neighborAnimals(AnimalEnum.Hawk + 1)             
                    loneHawkCount = loneHawkCount + 1;
                end

            end

            if loneHawkCount
                if loneHawkCount > length(scoreArray)
                    score = scoreArray(end);
                else
                    score = scoreArray(loneHawkCount);
                end
            end
        end

        function score = ruleBScore(obj, environment)
            scoreArray = [0 5 9 12 16 20 24 28];
            hawkTiles = getAllAnimalTiles(obj, environment, AnimalEnum.Hawk);
            loneHawkCount = 0;

            for i = 1:length(hawkTiles)
                currTile = hawkTiles(i);
                neighborAnimals = getAdjacentAnimals(obj, environment, currTile);

                hasLineOfSight = hasLineOfSight(obj, currTile, environment);

                if ~neighborAnimals(AnimalEnum.Hawk + 1) && hasLineOfSight             
                    loneHawkCount = loneHawkCount + 1;
                end
            end

            if loneHawkCount
                if loneHawkCount > length(scoreArray)
                    score = scoreArray(end);
                else
                    score = scoreArray(loneHawkCount);
                end
            end
        end

        function score = ruleCScore(obj, environment)
            score = 0;
        end

        function score = ruleDScore(obj, environment)
            score = 0;
        end

    end

    methods(Access = private)
        function [tf, losCoords] = hasLineOfSight(obj, tile, env)
            % Determined whether a particular hawk in an environment has
            % line of sight with another hawk, and the coordinates of all
            % lines of sight that it has. 

            % Check in increasing radius -- until when? 


            tf = false;
            losCoords = [];

        end
    end
end

