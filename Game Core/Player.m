classdef Player
    %PLAYER Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Environment Environment % The game map
        NatureTokens (1,1) uint8 % Number of tokens
        Name char
        AvailableActions MovesEnum % Current legal moves
        UsedVoluntaryOverpopulationWipe logical
    end

    methods
        function obj = Player()
            %PLAYER Construct an instance of this class
            %   Detailed explanation goes here
            obj.Environment = Environment();
            obj.NatureTokens = 0;
            obj.UsedVoluntaryOverpopulationWipe = false;
        end

        function [gameObj, playerObj] = getAvailableActions(playerObj, gameObj)
            % Auto overpopulation wipe
            numAnimals = gameObj.countSameCenterAnimals();          
            while numAnimals == gameObj.GameParameters.CenterTiles 
                disp('Auto overpopulation wipe!')          
                gameObj = MovesEnum.overpopulationWipe(gameObj);
                numAnimals = gameObj.countSameCenterAnimals();
            end

            playerObj.AvailableActions = MovesEnum.checkMoveAvailability(gameObj, playerObj);
        end

    end
end