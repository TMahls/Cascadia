function drawHabitatTile(ax, centerX, centerY, size, habitatTile)
%DRAWHABITATTILE Summary of this function goes here
%   Detailed explanation goes here

colors = ColorEnum.empty;
for j = 1:length(habitatTile.Terrain)
    colors(j) = getColor(habitatTile.Terrain(j));
end

% 1 Terrain - One hexagon

% 2 Terrain - Two hexagon halves

end