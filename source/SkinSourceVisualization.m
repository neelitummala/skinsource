classdef SkinSourceVisualization
%
% SKINSOURCEVISUALIZATION  Returns a SKINSOURCEVISUALIZATION object that 
%   allows users to visualize skin vibrations on the hand and arm in
%   several different ways: upper limb RMS vibrations, vibrations
%   across the upper limb at consecutive timesteps, and time- or
%   frequency-domain signals at selected points on the hand. 
%   Note that all plotting on the 2D surface is only for the dorsal surface
%   of the upper limb.
%
%   USAGE
%       skinsourceVis = SKINSOURCEVISUALIZATION(locations, model,
%           constants)
%
%   PROPERTIES
%       locations - Vector of input locations. Must be within [1, 20].
%       model - Upper limb model number. Must be within [1, 4].
%       constants - Struct of constants. Can be loaded from Constants.m.
%       scaleFactor - Scale factor mapping from pixel space to mm for the
%           selected upper limb model.
%       surface - MATLAB polyshape object for the 2D representation of the
%           dorsal surface of the upper limb.
%       outputLocations - Output locations on the 2D surface.
%
%   METHODS
%       plotrmsvibrations - Plots the RMS (root mean square)of skin 
%           vibrations across the dorsal surface of the upper limb.
%       plottimestepvibrations - Plots the skin vibrations at selected 
%           timesteps across the dorsal surface of the upper limb.
%       plotselectedtimedomainvibrations - Plots the skin vibrations at
%           selected locations on the dorsal surface of the upper limb.
%       plotselectedfrequencydomainsignals - Plots the frequency magnitude
%           spectrums of vibrations at selected locations on the dorsal
%           surface of the upper limb.
%    


    % Public properties of the SkinSourceVisualization class
    properties (Access=public)
        locations
        model
        constants
        scaleFactor
        surface
        outputLocations
    end


    % Private properties of the SkinSourceVisualization class
    properties (Access=private)
        inputLocations
        adjacencyMatrix
        mask
    end


    % Public methods
    methods (Access = public)


        function obj = SkinSourceVisualization(locations, model, ...
                constants)
            % SKINSOURCEVISUALIZATION  initializes SkinSourceVisualization
            %   object.
            %
            %   USAGE
            %       skinsourceVis = SKINSOURCEVISUALIZATION(locations, 
            %           model, constants)
            %
            %   INPUT PARAMETERS
            %       locations - Vector of input locations. Must be
            %           within [1, 20].
            %       model - Upper limb model number. Must be within 
            %           [1, 4].
            %       constants - Struct of constants. Can be loaded from
            %           Constants.m.
            %
            %   OUTPUT PARAMETERS
            %       obj - SkinSourceVisualization object.
            %

            obj.locations = locations;
            obj.model = model;
            obj.constants = constants;  

            obj.scaleFactor = ...
                obj.constants.PIXEL_TO_MM_SCALE_FACTORS(model);

            obj.surface = scale(getsurface(obj), obj.scaleFactor);
            allInputLocations = getinputlocations(obj)*obj.scaleFactor;
            obj.inputLocations = allInputLocations(obj.locations, :);
            obj.outputLocations = getoutputlocations(obj)*obj.scaleFactor;
            obj.adjacencyMatrix = getadjacencymatrix(obj)*obj.scaleFactor;
            obj.mask = getmask(obj, obj.model);
        end
        
        function plotrmsvibrationsGUI(obj, vibrations, interpolationType)
            %
            % PLOTRMSVIBRATIONSGUI  plots the root mean square (RMS) of the
            %   vibrations across the dorsal upper limb surface  for
            %   visualization in SkinSourceGUI.m.
            %
            %   USAGE
            %       rmsVibrations = PLOTRMSVIBRATIONSGUI(vibrations,
            %           interpolationType, display)
            %
            %   INPUT PARAMETERS
            %       vibrations - Skin vibrations across the hand. Must be
            %           single-axis. Dimensions should be (nTimesteps,
            %           nLocations).
            %       interpolationType - Type of interpolation to use on the
            %           surface. Can be 'natural', 'linear', 'cubic',
            %           'v4', or 'nearest'.
            %
            
            rmsVibrations = mag2db(squeeze(rms(vibrations, 1)));

            plotonsurfaceGUI(rmsVibrations, obj.surface, ...
                obj.outputLocations, obj.adjacencyMatrix, ...
                obj.mask, interpolationType);
        end


        function plotrmsvibrations(obj, vibrations, interpolationType)
            %
            % PLOTRMSVIBRATIONS  plots the root mean square (RMS) of the
            %   vibrations across the dorsal upper limb surface.
            %
            %   USAGE
            %       rmsVibrations = PLOTRMSVIBRATIONS(vibrations, 
            %           interpolationType)
            %
            %   INPUT PARAMETERS
            %       vibrations - Skin vibrations across the hand. Must be
            %           single-axis. Dimensions should be (nTimesteps,
            %           nLocations).
            %       interpolationType - Type of interpolation to use on the
            %           surface. Can be 'natural', 'linear', 'cubic',
            %           'v4', or 'nearest'.
            %
            
            rmsVibrations = mag2db(squeeze(rms(vibrations, 1)));

            plotonsurface(rmsVibrations, obj.surface, ...
                obj.outputLocations, obj.adjacencyMatrix, ...
                obj.mask, interpolationType);

            title('RMS accelerations (dB re. 1 m/s^2)')

        end


        function plottimestepvibrations(obj, vibrations, timesteps, ...
                interpolationType, scale)
            %
            % PLOTTIMESTEPVIBRATIONS  plots skin vibrations across the 
            %   dorsal surface of the upper limb at selected timesteps.
            %
            %   USAGE
            %       PLOTTIMESTEPVIBRATIONS(vibrations, timesteps, 
            %           interpolationType)
            %       PLOTTIMESTEPVIBRATIONS(vibrations, timesteps, 
            %           interpolationType, scale)
            %
            %   INPUT PARAMETERS
            %       vibrations - Skin vibrations across the hand. Must be
            %           single-axis. Dimensions should be (nTimesteps,
            %           nLocations).
            %       timesteps - Vector of timesteps (s) at which to select
            %           the skin vibrations.
            %       interpolationType - Type of interpolation to use on the
            %           surface. Can be 'natural', 'linear', 'cubic',
            %           'v4', or 'nearest'.
            %       scale - Boolean for scaling the plots to the maximum 
            %           range over all timesteps. (Optional, default is 1.)
            %

            if nargin < 5
                scale = 1;
            end

            % Convert timesteps to samples
            timestepSamples = round(timesteps*obj.constants.FS);

            % Get min and max values to set the colorbar limits
            maxVal = max(vibrations(timestepSamples, :), [], 'all');
            minVal = min(vibrations(timestepSamples, :), [], 'all');
            
            % Whole-surface vinrations at selected timesteps
            for ii=1:length(timesteps)

                timestepData = vibrations(timestepSamples(ii), :);

                plotonsurface(timestepData, obj.surface, ...
                    obj.outputLocations, obj.adjacencyMatrix, ...
                    obj.mask, interpolationType)

                title(sprintf('Skin acceleration (m/s^2) at %s ms', ...
                    num2str(timesteps(ii)*1000)))

                if scale
                    caxis([minVal, maxVal])
                end

            end
        end


        function plotselectedtimedomainvibrations(obj, vibrations, ...
                selectedLocations, scale)
            %
            % PLOTSELECTEDTIMEDOMAINVIBRATIONS  plots the vibrations at
            %   selected output locations in the time domain.
            %
            %   USAGE
            %       PLOTSELECTEDTIMEDOMAINVIBRATIONS(vibrations, 
            %           selectedLocations)
            %       PLOTSELECTEDTIMEDOMAINVIBRATIONS(vibrations, 
            %           selectedLocations, scale)
            %
            %   INPUT PARAMETERS
            %       vibrations - Skin vibrations across the surface. 
            %           Must be single-axis. Dimensions should be 
            %           (nTimesteps, nLocations).
            %       selectedLocations - Indices of output locations at
            %           which to plot the vibrations in the time domain.
            %       scale - Boolean for scaling the plots to the maximum 
            %           range over all locations. (Optional, default is 1.)
            %

            if nargin < 4
                scale = 1;
            end

            nLocations = length(selectedLocations);
            t = 1000*(0:size(vibrations, 1)-1)/obj.constants.FS;

            % Get min and max values to set the plot limits
            maxVal = max(abs(vibrations(:, selectedLocations)), [], 'all');
            
            figure('Position', [60, 60, 500, 500]);

            for ii=1:nLocations

                selectedSignal = vibrations(:, selectedLocations(ii));

                subplot(nLocations, 1, ii);
                hold on;

                plot(t, selectedSignal);

                xlabel('Time (ms)')
                ylabel('Acceleration (m/s^2)')
                title(sprintf('Location %s', ...
                    num2str(selectedLocations(ii))))

                if scale
                    ylim([-maxVal, maxVal])
                end

                xlim([t(1), t(end)])

            end

            % Plot hand with selected locations
            figure('Position', [60, 60, 500, 500]);
            hold on;
            axis equal;

            plot(obj.surface, 'FaceAlpha', 0);
            scatter(obj.outputLocations(selectedLocations, 1), ...
                obj.outputLocations(selectedLocations, 2), 'filled')

            for ii=1:nLocations
                text(obj.outputLocations(selectedLocations(ii), 1)+1, ...
                    obj.outputLocations(selectedLocations(ii), 2)+1, ...
                    num2str(selectedLocations(ii)), 'Color', 'r')
            end

        end


        function plotselectedfrequencydomainsignals(obj, f, spectrums, ...
                selectedLocations, smooth, scale)
            %
            % PLOTSELECTEDFREQUENCYDOMAINSIGNALS  plots the single-sided 
            %   frequency magnitude spectrums of the skin vibrations at
            %   selected output locations.
            %
            %   USAGE
            %       PLOTSELECTEDFREQUENCYDOMAINSIGNALS(f, spectrums, 
            %           selectedLocations, smooth)
            %       PLOTSELECTEDFREQUENCYDOMAINSIGNALS(f, spectrums, 
            %           selectedLocations, smooth, scale)
            %
            %   INPUT PARAMETERS
            %       f - Frequencies for the spectrums (Hz).
            %       spectrums - Single-sided frequency magnitude spectrums 
            %           for skin vibrations at all output locations on the 
            %           surface. Must be single-axis. Dimensions should be 
            %           (nFrequencies, nLocations).
            %       selectedLocations - Indices of output locations at
            %           which to plot the frequency spectrums.
            %       smooth - Boolean for smoothing the frequency spectrums
            %           using a moving mean with a window size of 10.
            %       scale - Boolean for scaling the plots to the maximum 
            %           range over all locations. (Optional, default is 1.)
            %

            if nargin < 6
                scale = 1;
            end

            nLocations = length(selectedLocations);

            % Get min and max values to set the plot limits
            maxVal = max(mag2db(spectrums(:, selectedLocations)), [], ...
                'all');
            minVal = min(mag2db(spectrums(:, selectedLocations)), [], ...
                'all');
            
            figure('Position', [60, 60, 500, 500]);
            for ii=1:nLocations

                selectedSignal = ...
                    mag2db(spectrums(:, selectedLocations(ii)));

                if smooth
                    selectedSignal = movmean(selectedSignal, 10);
                end

                subplot(nLocations, 1, ii);
                hold on;

                plot(f, selectedSignal);

                title(sprintf('Location %s', ...
                    num2str(selectedLocations(ii))))

                if scale
                    ylim([minVal, maxVal])
                end

                xlim([25, 600])

                if ii==nLocations
                    xlabel('Frequency (Hz)')
                    ylabel('Magnitude (dB re. 1 m/s^2)')
                end

            end

            % Plot hand with selected locations

            figure('Position', [60, 60, 500, 500]);
            hold on;
            axis equal;

            plot(obj.surface, 'FaceAlpha', 0);
            scatter(obj.outputLocations(selectedLocations, 1), ...
                obj.outputLocations(selectedLocations, 2), 'filled')

            for ii=1:nLocations

                text(obj.outputLocations(selectedLocations(ii), 1)+2, ...
                    obj.outputLocations(selectedLocations(ii), 2)+2, ...
                    num2str(selectedLocations(ii)), 'Color', 'r')

            end

        end

    end


    % Private methods
    methods(Access = private)
        
        function surface = getsurface(obj)
            load(obj.constants.SURFACE_PATH, 'surface');
        end


        function mask = getmask(obj, model)
            load(strcat(obj.constants.MASK_PATH, int2str(model), ...
                '.mat'), 'mask');
        end


        function inputLocations = getinputlocations(obj)
            load(obj.constants.INPUT_LOCATIONS_PATH, 'inputLocations');
        end


        function outputLocations = getoutputlocations(obj)
            load(obj.constants.OUTPUT_LOCATIONS_PATH, 'outputLocations');
        end


        function adjacencyMatrix = getadjacencymatrix(obj)
            load(obj.constants.ADJACENCY_MATRIX_PATH, 'adjacencyMatrix');
        end
        
    end

end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}