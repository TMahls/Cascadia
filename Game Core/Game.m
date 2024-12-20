classdef Game
    %GAME Summary of this class goes here
    %   Detailed explanation goes here

    properties
        GameParameters GameParameters % Constant properties for all games
        Players Player % Array of Player
        StarterHabitatTiles HabitatTile % Array of 'StartHabitatTiles', which is an array of 3 tiles...
        HabitatTiles HabitatTile % Array of HabitatTile
        WildlifeTokens WildlifeToken % Array of WildlifeToken
        NatureTokens uint8 % Array of size NumWildlifeTokens, value is status

        TurnCount % How many turns has the game gone?
        PlayerTurn % Who's turn is it?
        CurrentScores table % Scores for current turn
    end

    methods
        function obj = Game()
            %GAME Construct an instance of this class
            %   Detailed explanation goes here

            % Get parameter data store
            obj.GameParameters = GameParameters();

            % Populate empty player
            obj.Players = Player.empty;

            % Populate Starter Habitat Tiles
            obj.StarterHabitatTiles = initStarterTiles(obj.GameParameters);

            % Populate Habitat Tiles
            obj.HabitatTiles = initHabitatTiles(obj.GameParameters);

            % Populate Wildlife Tokens
            obj.WildlifeTokens = initWildlifeTokens(obj.GameParameters);

            % Populate Nature Tokens
            obj.NatureTokens = initNatureTokens(obj.GameParameters);
        end

        function obj = startNewGame(obj, nPlayers)
            %STARTNEWGAME Summary of this method goes here
            %   Detailed explanation goes here

            % Select subset of all habitat tiles to make 'Hidden'
            numInPlayTiles = obj.GameParameters.habitatTilesForNPlayers(nPlayers);
            idx = randperm(obj.GameParameters.calculateTotalHabitatTiles, numInPlayTiles);
            for i = idx
                obj.HabitatTiles(i).Status = StatusEnum.Hidden;
            end

            % Give player a random starting tile
            idx = randperm(obj.GameParameters.StarterTiles, nPlayers);
            for i = 1:nPlayers
                obj.Players(i) = Player();

                % Set player name (only default for now)
                obj.Players(i).Name = ['Player ' num2str(i)];

                % Set starter tile status as 'Played'
                for j = 1:length(obj.StarterHabitatTiles(idx(i),:))
                    obj.StarterHabitatTiles(idx(i),j).Status = StatusEnum.Played;
                end

                obj.Players(i).Environment.StarterHabitatTile = obj.StarterHabitatTiles(idx(i),:);
            end

            % Center Habitat Tiles and Wildlife tokens
            idx = sort(randperm(numInPlayTiles, obj.GameParameters.CenterTiles));
            inPlayCount = 0;
            for i = 1:length(obj.HabitatTiles)
                if (obj.HabitatTiles(i).Status == StatusEnum.Hidden)
                    inPlayCount = inPlayCount + 1;
                end

                if any(inPlayCount == idx)
                    obj.HabitatTiles(i).Status = StatusEnum.InCenter;
                end
            end

            idx = randperm(length(obj.WildlifeTokens), obj.GameParameters.CenterTiles);
            for i = idx
                obj.WildlifeTokens(i).Status = StatusEnum.InCenter;
            end

            % Start game
            obj.TurnCount = 1;
            obj.PlayerTurn = 1;
            obj.CurrentScores = obj.GameParameters.initScoreTable(obj.Players);
            fprintf('Game started!\n');

            obj.Players(obj.PlayerTurn) = obj.Players(obj.PlayerTurn).getAvailableActions;
        end

        function playerAction(obj, action)
            %PLAYERACTION Summary of this method goes here
            % Callback triggered by a player selecting a move

            currPlayer = obj.Players(obj.PlayerTurn);

            if ismember(action, currPlayer.AvailableActions)
                % Execute selected move
                currPlayer.execute(action);

                % Check if player can continue turn, or if game is over
                currPlayer = currPlayer.getAvailableActions;
                turnOver = false; gameOver = false;
                if countTiles(obj, StatusEnum.Hidden) == 0
                    gameOver = true;
                elseif isempty(currPlayer.AvailableActions)
                    turnOver = true;
                end

                if turnOver || gameOver
                    % Update player's score
                    % Where to put this method... here? 
                    otherPlayers = obj.Players;
                    otherPlayers(obj.PlayerTurn) = [];
                    obj.Players(obj.PlayerTurn) = ...
                        updateScore(obj.Players(obj.PlayerTurn), obj.GameParameters, otherPlayers);
                end

                if gameOver
                    % Print scores, announce winner
                elseif turnOver
                    % Replace Center
                    randTile = HabitatTile();
                    while (randTile.Status ~= StatusEnum.Hidden)
                        tileIdx = randi(length(obj.HabitatTiles));
                        randTile = obj.HabitatTiles(tileIdx);
                    end

                    randToken = [];
                    while (randToken.Status ~= StatusEnum.Hidden)
                        tokenIdx = randi(length(obj.WildlifeTokens));
                        randToken = obj.WildlifeTokens(tokenIdx);
                    end

                    obj.HabitatTiles(tileIdx).Status = StatusEnum.InCenter;
                    obj.WildlifeTokens(tokenIdx).Status = StatusEnum.InCenter;

                    % Prepare for next player's turn
                    obj.TurnCount = obj.TurnCount + 1;
                    obj.PlayerTurn = mod(obj.PlayerTurn, length(obj.Players)) + 1;
                    fprintf('Player %d''s Turn\n', obj.PlayerTurn);
                    obj.Players(obj.PlayerTurn) = obj.Players(obj.PlayerTurn).getAvailableActions;
                else
                    fprintf('Player %d Continues Turn\n', obj.PlayerTurn);
                end
            else
                fprintf('Action not available to player!');
            end
        end
    end

    methods (Access = private)
        function nTiles = countTiles(obj, status)
            %COUNTTILES How many tiles of a particular status exist
            %   Detailed explanation goes here
            nTiles = 0;
            for i = 1:length(obj.HabitatTiles)
                if obj.HabitatTiles(i).Status == status
                    nTiles = nTiles + 1;
                end
            end
        end

        function nTokens = countTokens(obj, status)
            %COUNTTOKENS How many tokens of a particular status exist
            %   Detailed explanation goes here
            nTokens = 0;
            for i = 1:length(obj.WildlifeTokens)
                if obj.WildlifeTokens(i).Status == status
                    nTokens = nTokens + 1;
                end
            end
        end
    end
end