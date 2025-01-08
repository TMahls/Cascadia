function drawHabitatTile(ax, centerCoords, sideLength, habitatTile, id)
%DRAWHABITATTILE Summary of this function goes here
%   id - Tile type
%   If > 0, we assume this is a center tile and give it a UserData of id
%   If 0, a normal environment tile, no user data applied
%   If -1, a preview tile and we give it a thick gold border. 

colors = ColorEnum.empty;
for i = 1:length(habitatTile.Terrain)
    colors(i) = getColor(habitatTile.Terrain(i));
end

nPoints = 6;
pshapes = polyshape.empty;
if isscalar(colors)
    % 1 Terrain - One hexagon
    pshapes = nsidedpoly(nPoints,'Center',centerCoords,'SideLength',sideLength);
    pshapes = rotate(pshapes,180/nPoints,centerCoords);
elseif length(colors) == 2
    % 2 Terrain - Two hexagon halves
    % The angle of hexagon vertexes (in degrees) from x axis
    % Could have used rotate for this but eh
    startAngle = 90 - 60*(double(habitatTile.Orientation) - 1);
    pointAngles = linspace(startAngle, startAngle + 360, nPoints + 1);
    points = [centerCoords(1) + sideLength*cosd(pointAngles)', ...
        centerCoords(2) + sideLength*sind(pointAngles)'];

    pshapes(1) = polyshape(points(1:(nPoints/2 + 1),:));
    pshapes(2) = polyshape(points((nPoints/2 + 1):end,:));
end

plotPolyshapeComponents(ax, pshapes, colors, id);

plotCompatibleToken = false;
% Plot Wildlife Tokens or Compatibility Markers
if isempty(habitatTile.WildlifeToken.Animal)
    % Plot Compatible wildlife markers
    plotCompatibleToken = true;
    colors = ColorEnum.empty;
    animals = AnimalEnum.empty;
    for i = 1:length(habitatTile.CompatibleWildlife)
        colors(i) = getColor(habitatTile.CompatibleWildlife(i));
        animals(i) = habitatTile.CompatibleWildlife(i);
    end
    
    if isscalar(colors)
        % 1 Compatible Wildlife - One circle
    elseif length(colors) == 2
        % 2 Compatible Wildlife
        centerCoords = [centerCoords(1), centerCoords(2) + sideLength/6; ...
            centerCoords(1), centerCoords(2) - sideLength/6];
    elseif length(colors) == 3
        % 3 Compatible Wildlife
        innerTriangle = nsidedpoly(3,'Center',centerCoords,'SideLength',sideLength/3);
        centerCoords = innerTriangle.Vertices;
    end
else
    % Plot played token
    animals = habitatTile.WildlifeToken.Animal;
end

ids = zeros(size(animals));
for i = 1:length(animals)
    if plotCompatibleToken
        currToken = WildlifeToken();
        currToken.Animal = habitatTile.CompatibleWildlife(i); 
        ids(i) = -2;
    else
        currToken = habitatTile.WildlifeToken;
        ids(i) = 0;
    end
    drawWildlifeToken(ax, centerCoords(i,:), sideLength, currToken, ids(i));
end
end

function plotPolyshapeComponents(ax, pshapes, faceColors, id)
for i = 1:length(pshapes)
    currColor = faceColors(i).rgbValues;
    if id >= 0
        pgon = plot(ax, pshapes(i), 'FaceColor', currColor, 'FaceAlpha',1,...
            'EdgeColor',ColorEnum.Black.rgbValues);
        if id > 0
            pgon.UserData = id;
        end
    else
        % Preview tile
        pgon = plot(ax, pshapes(i), 'FaceColor', currColor, 'FaceAlpha',1,...
            'EdgeColor',ColorEnum.Gold.rgbValues, 'LineWidth', 3);
    end

    pgon.HitTest = 'off'; % Clicking will trigger UIAxes callback
end
end