% This script can be used as a sandbox for testing things out

clear;clc;
tic
obj = Game;
obj = obj.startNewGame(3);
toc


% Test out graphics
drawCenter(obj);

% Try out moves
% for n = 1:100
% 
% obj.WildlifeTokens(obj.CenterTokenIdx).Animal;
% 
% obj.Players(1).AvailableActions
% 
% if ismember(MovesEnum.OverpopulationWipe, obj.Players(1).AvailableActions)
%     fprintf('Performing voluntary overpop wipe\n');
%     obj = playerAction(obj, MovesEnum.OverpopulationWipe, []);
% 
% 
%     obj.WildlifeTokens(obj.CenterTokenIdx).Animal;
% 
%     obj.Players(1).AvailableActions
% 
%     obj.CurrentScores;
% end
% end





% See starter Tiles
% for nStarterTile = 1:5
%     for tileNum = 1:3
%         obj.StarterHabitatTiles(nStarterTile, tileNum)
%     end
% end
% 
% % See habitat tiles
for nHabitatTile = 1:length(obj.HabitatTiles)
    tile = obj.HabitatTiles(nHabitatTile);
    if tile.Status == StatusEnum.InCenter
        tile
    end
end

