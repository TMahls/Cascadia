function drawHabitatTile(ax, centerCoords, sideLength, habitatTile, id)
%DRAWHABITATTILE Summary of this function goes here
%   id - Tile type
%   If > 0, we assume this is a center tile and give it a UserData of id
%   If 0, a normal environment tile, no user data applied
%   If -1, a preview tile and we make it semitransparent with gold border. 

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

% Plot Wildlife Tokens or Compatibility Markers
nPoints = 20; % A dodecagon is basically a circle right? :)

if isempty(habitatTile.WildlifeToken.Animal)
    % Plot Compatible wildlife markers
    colors = ColorEnum.empty;
    for i = 1:length(habitatTile.CompatibleWildlife)
        colors(i) = getColor(habitatTile.CompatibleWildlife(i));
    end
    
    pshapes = polyshape.empty;
    if isscalar(colors)
        % 1 Compatible Wildlife - One circle
        pshapes = nsidedpoly(nPoints,'Center',centerCoords,'SideLength',sideLength/15);
    elseif length(colors) == 2
        % 2 Compatible Wildlife
        pshapes(1) = nsidedpoly(nPoints,'Center',[centerCoords(1), centerCoords(2) + sideLength/5],'SideLength',sideLength/15);
        pshapes(2) = nsidedpoly(nPoints,'Center',[centerCoords(1), centerCoords(2) - sideLength/5],'SideLength',sideLength/15);
    elseif length(colors) == 3
        % 3 Compatible Wildlife
        innerTriangle = nsidedpoly(3,'Center',centerCoords,'SideLength',sideLength/3);
        vertices = innerTriangle.Vertices;
        pshapes(1) = nsidedpoly(nPoints,'Center',vertices(1,:),'SideLength',sideLength/15);
        pshapes(2) = nsidedpoly(nPoints,'Center',vertices(2,:),'SideLength',sideLength/15);
        pshapes(3) = nsidedpoly(nPoints,'Center',vertices(3,:),'SideLength',sideLength/15);
    end
else
    % Plot played token
    colors = getColor(habitatTile.WildlifeToken.Animal);
    pshapes = nsidedpoly(nPoints,'Center',centerCoords,'SideLength',sideLength/10);
end

plotPolyshapeComponents(ax, pshapes, colors, 0);

end

function plotPolyshapeComponents(ax, pshapes, faceColors, id)
for n = 1:length(pshapes)
    currColor = faceColors(n).rgbValues;
    if id >= 0
        pgon = plot(ax, pshapes(n), 'FaceColor', currColor, 'FaceAlpha',1,...
            'EdgeColor',ColorEnum.Black.rgbValues);
        if id > 0
            pgon.UserData = id;
        end
    else
        % Preview tile
        pgon = plot(ax, pshapes(n), 'FaceColor', currColor, 'FaceAlpha',1,...
            'EdgeColor',ColorEnum.Gold.rgbValues);
    end

    pgon.HitTest = 'off'; % Clicking will trigger UIAxes callback
end
end