function drawHabitatTile(ax, centerX, centerY, sideLength, habitatTile, id)
%DRAWHABITATTILE Summary of this function goes here
%   Detailed explanation goes here

colors = ColorEnum.empty;
for i = 1:length(habitatTile.Terrain)
    colors(i) = getColor(habitatTile.Terrain(i));
end

nPoints = 6;
pshapes = polyshape.empty;
if isscalar(colors)
    % 1 Terrain - One hexagon
    pshapes = nsidedpoly(nPoints,'Center',[centerX centerY],'SideLength',sideLength);
    pshapes = rotate(pshapes,180/nPoints,[centerX centerY]);
elseif length(colors) == 2
    % 2 Terrain - Two hexagon halves
    % The angle of hexagon vertexes (in degrees) from x axis
    pointAngles = linspace(90, 360 + 90, nPoints + 1);
    points = [centerX + sideLength*cosd(pointAngles)', centerY + sideLength*sind(pointAngles)'];

    pshapes(1) = polyshape(points(1:(nPoints/2 + 1),:));
    pshapes(2) = polyshape(points((nPoints/2 + 1):end,:));
end

plotPolyshapeComponents(ax, pshapes, colors, id);

% Plot Compatible wildlife markers
colors = ColorEnum.empty;
for i = 1:length(habitatTile.CompatibleWildlife)
    colors(i) = getColor(habitatTile.CompatibleWildlife(i));
end

nPoints = 20; % A dodecagon is basically a circle right? :)
pshapes = polyshape.empty;
if isscalar(colors)
    % 1 Compatible Wildlife - One circle
    pshapes = nsidedpoly(nPoints,'Center',[centerX centerY],'SideLength',sideLength/15);
elseif length(colors) == 2
    % 2 Compatible Wildlife
    pshapes(1) = nsidedpoly(nPoints,'Center',[centerX, centerY + sideLength/5],'SideLength',sideLength/15);
    pshapes(2) = nsidedpoly(nPoints,'Center',[centerX, centerY - sideLength/5],'SideLength',sideLength/15);
elseif length(colors) == 3
    % 3 Compatible Wildlife
    innerTriangle = nsidedpoly(3,'Center',[centerX centerY],'SideLength',sideLength/3);
    vertices = innerTriangle.Vertices;
    pshapes(1) = nsidedpoly(nPoints,'Center',vertices(1,:),'SideLength',sideLength/15);
    pshapes(2) = nsidedpoly(nPoints,'Center',vertices(2,:),'SideLength',sideLength/15);
    pshapes(3) = nsidedpoly(nPoints,'Center',vertices(3,:),'SideLength',sideLength/15);
end

plotPolyshapeComponentsNoUserData(ax, pshapes, colors);

end

function plotPolyshapeComponents(ax, pshapes, faceColors, id)
for n = 1:length(pshapes)
    currColor = faceColors(n).rgbValues;
    pgon = plot(ax, pshapes(n), 'FaceColor', currColor, 'FaceAlpha',1,...
        'EdgeColor',ColorEnum.Black.rgbValues);
    pgon.HitTest = 'off'; % Clicking will trigger UIAxes callback
    pgon.UserData = id;
end
end

function plotPolyshapeComponentsNoUserData(ax, pshapes, faceColors)
for n = 1:length(pshapes)
    currColor = faceColors(n).rgbValues;
    pgon = plot(ax, pshapes(n), 'FaceColor', currColor, 'FaceAlpha',1,...
        'EdgeColor',ColorEnum.Black.rgbValues);
    pgon.HitTest = 'off'; % Clicking will trigger UIAxes callback
end
end