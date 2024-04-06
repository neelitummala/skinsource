function plotonsurface(data, surface, originalPoints, adjacencyMatrix, ...
    mask, interpolationType)
    % PLOTONSURFACE  interpolates and plots data on the 2D upper limb
    %   dorsal surface.
    %
    %   USAGE
    %       PLOTONSURFACE(data, surface, originalPoints, adjacencyMatrix,
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
    %           inside the hand surface and 0 otherwise.
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
    figure('Position', [60, 60, 500, 500]);
    imagesc((flipud(interpolatedValues)), 'AlphaData', ...
        ~isnan(flipud(interpolatedValues)));
    set(gca, 'color', 'none')
    axis equal
    colorbar

end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}