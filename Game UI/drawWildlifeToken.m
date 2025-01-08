function drawWildlifeToken(ax, centerCoords, hexSideLength, wildlifeToken, id)
%DRAWHABITATTILE Draws a wildlife token.
%   id - Token type
%   If > 0, we assume this is a center token and give it a UserData of id
%   If 0, a played token, no user data applied
%   If -1, a preview token and we give it a thick gold border.
%   If -2, a widlife compatibility token. Smaller

color = getColor(wildlifeToken.Animal);
nSides = 20;
switch id
    case -2
        pshape = nsidedpoly(nSides,"Center",centerCoords,'SideLength',hexSideLength/15);
        line = plot(ax, pshape, 'FaceColor', color.rgbValues, 'FaceAlpha',1,...
    'EdgeColor', ColorEnum.Black.rgbValues);
    case -1
        pshape = nsidedpoly(nSides,"Center",centerCoords,'SideLength',hexSideLength/8);
        line = plot(ax, pshape, 'FaceColor', color.rgbValues, 'FaceAlpha',1,...
    'EdgeColor', ColorEnum.Gold.rgbValues, 'LineWidth', 3);
    case 0
        pshape = nsidedpoly(nSides,"Center",centerCoords,'SideLength',hexSideLength/8);
        line = plot(ax, pshape, 'FaceColor', color.rgbValues, 'FaceAlpha',1,...
    'EdgeColor', ColorEnum.Black.rgbValues);
    otherwise
        pshape = nsidedpoly(nSides,"Center",centerCoords,'SideLength',hexSideLength/6);
        line = plot(ax, pshape, 'FaceColor', color.rgbValues, 'FaceAlpha',1,...
            'EdgeColor', ColorEnum.Black.rgbValues);
        line.UserData = id;
end

line.HitTest = 'off'; % Clicking will trigger UIAxes callback

end
