classdef Player
    %PLAYER Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Environment Environment % The game map
        NatureTokens (1,1) uint8 % Number of tokens
        Name char

        AvailableActions MovesEnum % Current legal moves
        % Flags used to determine valid moves
        UsedVoluntaryOverpopulationWipe (1,1) logical
        SpentNatureToken (1,1) logical
        DecoupledTileToken (1,1) logical
        SelectedTileIdx (1,1) uint8
        SelectedTokenIdx (1,1) uint8
        TilePlaced (1,1) logical
        TokenPlaced (1,1) logical
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
            if numAnimals == gameObj.GameParameters.CenterTiles 
                disp('Auto overpopulation wipe!')          
                playerObj.AvailableActions = MovesEnum.OverpopulationWipe;
            else
                playerObj.AvailableActions = MovesEnum.checkMoveAvailability(gameObj, playerObj);
            end
        end

        function [gameObj, playerObj] = takeNatureToken(playerObj, gameObj)           
            nextTokenIdx = find(gameObj.NatureTokens == 0, 1);
            if ~isempty(nextTokenIdx)
                gameObj.NatureTokens(nextTokenIdx) = gameObj.PlayerTurn;
                playerObj.NatureTokens = playerObj.NatureTokens + 1;
            end
        end

        function obj = resetTurnFlags(obj)
            % Reset turn flags in preparation for the next turn
            obj.UsedVoluntaryOverpopulationWipe = false;
            obj.SpentNatureToken = false;
            obj.DecoupledTileToken = false;
            obj.SelectedTileIdx = 0;
            obj.SelectedTokenIdx = 0;
            obj.TilePlaced = false;
            obj.TokenPlaced = false;
        end

    end
end