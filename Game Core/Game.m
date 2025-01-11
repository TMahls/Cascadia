classdef Game
    %GAME Summary of this class goes here
    %   Detailed explanation goes here

    properties
        GameParameters GameParameters % Constant properties for all games
        Players Player % Array of Player
        StarterHabitatTiles HabitatTile % Array of 'StartHabitatTiles', which is an array of 3 tiles...
        HabitatTiles HabitatTile % Array of HabitatTile
        WildlifeTokens WildlifeToken % Array of WildlifeToken
        NatureTokens uint8 % Array of size NumWildlifeTokens, value is which player owns it (0 default)
        

        CenterTileIdx uint8 % Idx in 'HabitatTiles' of center tiles (in center order)
        CenterTokenIdx uint8 % Idx in 'NatureTokens' of center tiles (in center order)
        % 0 indicates empty center

        ScoringRules uint8 % Which scoring rule we're using
        TurnCount uint8 % How many turns has the game gone?
        PlayerTurn uint8 % Whose turn is it?
        CurrentScores table % Scores for current turn
        StatusMsg char % Current game status
    end

    methods
        function obj = Game()
            %GAME Construct an instance of this class
            %   Detailed explanation goes here

            % Get parameter data store
            obj.GameParameters = GameParameters();

            % Populate Starter Habitat Tiles
            obj.StarterHabitatTiles = initStarterTiles(obj.GameParameters);
        end

        function obj = startNewGame(obj, nPlayers, options)
            %STARTNEWGAME Summary of this method goes here
            %  vararg in - game mode (default easy), custom scoring rules

            arguments 
                obj Game
                nPlayers (1,1) double
                options.GameMode = GameModeEnum.EasyRules
                options.CustomRules string = ""
                options.PlayerNames string = ""
            end

            % Set scoring rules
            obj.ScoringRules = obj.GameParameters.initScoringRules(...
                options.GameMode, options.CustomRules);
            
            % Reset players and tokens
            obj = clearPlayersAndTokens(obj);

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
            inPlayCount = 0; centerIdx = 1;
            for i = 1:length(obj.HabitatTiles)
                if (obj.HabitatTiles(i).Status == StatusEnum.Hidden)
                    inPlayCount = inPlayCount + 1;
                    if any(inPlayCount == idx)
                        obj.HabitatTiles(i).Status = StatusEnum.InCenter;
                        obj.CenterTileIdx(centerIdx) = i;
                        centerIdx = centerIdx + 1;
                    end
                end
            end

            idx = randperm(length(obj.WildlifeTokens), obj.GameParameters.CenterTiles);
            centerIdx = 1;
            for i = idx
                obj.WildlifeTokens(i).Status = StatusEnum.InCenter;
                obj.CenterTokenIdx(centerIdx) = i;
                centerIdx = centerIdx + 1;
            end

            % Start game
            obj.TurnCount = 1;
            obj.PlayerTurn = 1;
            obj.CurrentScores = obj.GameParameters.initScoreTable(obj.Players);
            obj.StatusMsg = 'Game started!';

            [obj, obj.Players(obj.PlayerTurn)] = ...
                obj.Players(obj.PlayerTurn).getAvailableActions(obj);
        end

        function obj = playerAction(obj, action, moveMetadata)
            %PLAYERACTION Summary of this method goes here
            % Callback triggered by a player selecting a move
            currPlayer = obj.Players(obj.PlayerTurn);

            if ismember(action, currPlayer.AvailableActions)
                originalPlayerIdx = obj.PlayerTurn;

                % Execute selected move
                obj.StatusMsg = [];
                [obj, currPlayer] = MovesEnum.executeMove(obj, currPlayer, action, moveMetadata);

                % Check if player can continue turn, or if game is over
                [obj, currPlayer] = currPlayer.getAvailableActions(obj);

                turnOver = isempty(currPlayer.AvailableActions);

                if turnOver
                    % Reset once-per-turn actions
                    currPlayer = resetTurnFlags(currPlayer);

                    % Update player's score
                    % We do this every turn for the purposes of the AI.
                    % It'll want to know ;)
                    obj.CurrentScores = calculateAllScores(obj);

                    gameOver = (countTiles(obj, StatusEnum.Hidden) == 0);

                    if gameOver
                        % Print scores, announce winner
                        obj.StatusMsg = 'Game over!';
                    elseif turnOver
                        % Replace Center
                        tileIdx = randi(length(obj.HabitatTiles));
                        randTile = obj.HabitatTiles(tileIdx);
                        while (randTile.Status ~= StatusEnum.Hidden)
                            tileIdx = randi(length(obj.HabitatTiles));
                            randTile = obj.HabitatTiles(tileIdx);
                        end

                        tokenIdx = randi(length(obj.WildlifeTokens));
                        randToken = obj.WildlifeTokens(tokenIdx);
                        while (randToken.Status ~= StatusEnum.Hidden)
                            tokenIdx = randi(length(obj.WildlifeTokens));
                            randToken = obj.WildlifeTokens(tokenIdx);
                        end

                        obj.HabitatTiles(tileIdx).Status = StatusEnum.InCenter;
                        obj.WildlifeTokens(tokenIdx).Status = StatusEnum.InCenter;

                        obj.CenterTileIdx(obj.CenterTileIdx == 0) = tileIdx;
                        obj.CenterTokenIdx(obj.CenterTokenIdx == 0) = tokenIdx;

                        % Prepare for next player's turn
                        obj.TurnCount = obj.TurnCount + 1;
                        obj.PlayerTurn = mod(obj.PlayerTurn, length(obj.Players)) + 1;
                        obj.StatusMsg = sprintf('Player %d''s Turn. %d Turns Remaining', obj.PlayerTurn, ...
                            countTiles(obj, StatusEnum.Hidden) + 1);
                        [obj, obj.Players(obj.PlayerTurn)] = ...
                            obj.Players(obj.PlayerTurn).getAvailableActions(obj);
                    end
                else
                    if isempty(obj.StatusMsg)
                        obj.StatusMsg = sprintf('Player %d Continues Turn', obj.PlayerTurn);
                    end
                end

                obj.Players(originalPlayerIdx) = currPlayer;
            else
                obj.StatusMsg = 'Action not available to player!';
            end
        end

        function nAnimals = countSameCenterAnimals(obj)
            % Count number of 'same animals' in the center. For overpopulation
            % purposes

            % Create array of center token animals
            tokenIndexes = obj.CenterTokenIdx;
            centerTokenAnimals = AnimalEnum.empty;
            idx = 1;
            for i = tokenIndexes
                if i ~= 0 % We could have a partially empty center when we check this
                    centerTokenAnimals(idx) = obj.WildlifeTokens(i).Animal;
                end
                idx = idx + 1;
            end

            % Count largest number of repeated animals
            nAnimals = 1;
            for i = 1:length(centerTokenAnimals)
                currAnimal = centerTokenAnimals(i);
                animalCount = 1;
                for j = (i+1):length(centerTokenAnimals)
                    if centerTokenAnimals(j) == currAnimal
                        animalCount = animalCount + 1;
                    end
                end
                if animalCount > nAnimals
                    nAnimals = animalCount;
                end
            end
        end

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

    methods (Access = private)
        function obj = clearPlayersAndTokens(obj)
            % Populate empty player
            obj.Players = Player.empty;

            % Populate Habitat Tiles
            obj.HabitatTiles = initHabitatTiles(obj.GameParameters);

            % Populate Wildlife Tokens
            obj.WildlifeTokens = initWildlifeTokens(obj.GameParameters);

            % Populate Nature Tokens
            obj.NatureTokens = initNatureTokens(obj.GameParameters);
        end
    end
end