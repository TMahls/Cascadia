function drawHabitatTile(ax, centerX, centerY, sideLength, habitatTile)
%DRAWHABITATTILE Summary of this function goes here
%   Detailed explanation goes here

colors = ColorEnum.empty;
for j = 1:length(habitatTile.Terrain)
    colors(j) = getColor(habitatTile.Terrain(j));
end

nPoints = 6;

if isscalar(colors)
% 1 Terrain - One hexagon
pgon = nsidedpoly(nPoints,'Center',[centerX centerY],'SideLength',sideLength);
pgon = rotate(pgon,180/nPoints,[centerX centerY]);
plot(ax,pgon,'FaceColor',colors.rgbValues,'FaceAlpha',1,...
    'EdgeColor',ColorEnum.Black.rgbValues);

elseif length(colors) == 2
% 2 Terrain - Two hexagon halves
% The angle of hexagon vertexes (in degrees) from x axis

pointAngles = linspace(90, 360 + 90, nPoints + 1);
points = [centerX + sideLength*cosd(pointAngles)', centerY + sideLength*sind(pointAngles)'];

half1 = polyshape(points(1:(nPoints/2 + 1),:));
half2 = polyshape(points((nPoints/2 + 1):end,:));
plot(ax,half1,'FaceColor',colors(1).rgbValues,'FaceAlpha',1,...
    'EdgeColor',ColorEnum.Black.rgbValues);
plot(ax,half2,'FaceColor',colors(2).rgbValues,'FaceAlpha',1,...
    'EdgeColor',ColorEnum.Black.rgbValues);
end

% Plot Compatible wildlife markers

end