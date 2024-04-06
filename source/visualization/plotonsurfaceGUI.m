function plotonsurfaceGUI(data, surface, originalPoints, adjacencyMatrix, ...
    mask, interpolationType)
    % PLOTONSURFACEGUI  interpolates and plots data on the 2D upper limb
    %   dorsal surface for visualization in SkinSourceGUI.m.
    %
    %   USAGE
    %       PLOTONSURFACEGUI(data, surface, originalPoints, adjacencyMatrix,
    %           interpolationType)
    %
    %   INPUT PARAMETERS
    %       data - Vector of data to plot on the 2D surface. Should have 
    %           length equal to the number of originalPoints.
    %       surface - MATLAB polyshape of 2D surface.
    %       originalPoints - Locations on the 2D surface corresponding to 
    %           each data value.
    %       adjacencyMatrix - Adjacency matrix for the boundary points on
    %           the 2D surface. Records distance between boundary points
    %           and originalPoints.
    %       mask - Binary matrix that is 1 when the interpolation point is
    %       inside the hand surface and 0 otherwise.
    %       interpolationType - Type of interpolation to use on the
    %           surface. Can be 'natural', 'linear', 'cubic', 'v4', or 
    %           'nearest'.
    %


    % Create grid of points to interpolate to based on the surface boundary
    % points
    vertices = surface.Vertices;
    [interpPointsX, interpPointsY] = ...
        meshgrid((min(vertices(:, 1)):max(vertices(:, 1))), ...
        (min(vertices(:, 2)):max(vertices(:, 2))));

    % Perform interpolation
    interpolatedValues = surfaceinterpolation(data, ...
        originalPoints, interpPointsX, interpPointsY, vertices, ...
        adjacencyMatrix, mask, interpolationType);
    

    % Plot

    imagesc((interpolatedValues'), 'AlphaData', ...
        ~isnan(interpolatedValues'));
    view(180,90);
    set(gca, 'color', 'none')
    axis equal
    grid off
    box off
    axis off
    cb = colorbar;
    ylabel(cb,'RMS Acceleration (dB - ref 1 m/s^2)','Rotation',270,'FontSize',12);
    cb.Label.Position(1) = 3;
    set(cb,'position',[.92 .1 .015 .3])
    
end



% Revision history:
%{
2023-10-22: v0.1 released.
%}