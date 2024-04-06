classdef SkinSource
%
% SKINSOURCE  Returns a SKINSOURCE object that allows users to input
%   mechanical stimuli to one or more input locations on the hand and
%   generate resulting output vibrations across the hand and arm. Users can
%   generate input signals such as sinusoids, noise, and taps. Users can 
%   also calculate the frequency magnitude spectrums of the resulting 
%   vibrations and project the vibrations from 3 axes to 1 axis.
%
%   USAGE
%       skinsource = SKINSOURCE(locations, model, 
%           impulseResponseType, constants)
%
%   PROPERTIES
%       locations - Vector of input locations. Must be within [1, 20].
%       model - Upper limb model number. Must be within [1, 4].
%       constants - Struct of constants. Can be loaded from Constants.m.
%       impulseResponses - Cell array of impulse responses. Length of cell
%           array should be the same as the number of input locations. Each
%           element of the cell array is the set of impulse responses
%           corresponding to that input location.
%
%   METHODS
%       getoutputvibrations - Calculates output vibrations given a set of
%           input stimuli.
%       projectvibrations - Projects vibrations from 3 axes to 1 axis.
%       getfrequencymagnitudespectrums - Calculates the single-sided
%           frequency magnitude spectrums of the vibrations.
%       generatesinusoidinput - Generates sinusoidal input stimuli.
%       generatewhitenoise - Generates white noise input stimuli.
%       generatetapinput - Generates tap input stimuli.
%    


    % Properties of the SkinSource class
    properties
        locations
        model
        constants
        impulseResponses        
    end


    % Public methods
    methods (Access = public)


        function obj = SkinSource(locations, model, constants)
            % SKINSOURCE  initializes a SkinSource object.
            %
            %   USAGE
            %       skinsource = SKINSOURCE(locations, model, 
            %           impulseResponseType, constants)
            %
            %   INPUT PARAMETERS
            %       locations - Vector of input locations. Must be
            %           within [1, 20].
            %       model - Upper limb model number. Must be within 
            %           [1, 4].
            %       impulseResponseType - Type of impulse responses to 
            %           use. Must be 'pulse' or 'ss'.
            %       constants - Struct of constants. Can be loaded from
            %           Constants.m.
            %
            %   OUTPUT PARAMETERS
            %       obj - SkinSource object.
            %

            obj.locations = locations;
            obj.model = model;
            obj.constants = constants;
            load(obj.constants.IMPULSE_RESPONSE_PATH, 'dataTable');
            obj.impulseResponses = dataTable;
            
        end


        function vibrations = getoutputvibrations(obj, stimuli, amplitudes)
            %
            % GETOUTPUTVIBRATIONS  determines the output skin vibrations
            %   given a set of stimuli.
            %
            %   USAGE
            %       vibrations = GETOUTPUTVIBRATIONS(stimuli, 
            %           desiredPeakToPeakAcceleration)
            %
            %   INPUT PARAMETERS
            %       stimuli - Cell array with stimulus vectors. Number of
            %           stimuli in the cell array should match the
            %           number of input locations. Stimuli should all be
            %           the same length.
            %       amplitudes - Desired maximum peak-to-peak accelerations 
            %           (mm/s^2) across the upper limb for output skin 
            %           vibrations resulting from the application of each 
            %           of the input stimuli.
            %
            %   OUTPUT PARAMETERS
            %       vibrations - Generated skin vibrations with
            %           dimensions (nTimesteps, nOutputLocations, nAxes).
            % 

            vibrations = outputvibrations(stimuli, amplitudes, ...
                obj.locations, obj.impulseResponses, obj.model);

        end


        function projectedVibrations = projectvibrations(obj, ...
                vibrations, projectionType, projectionAxes)
            % PROJECTVIBRATIONS  projects skin vibrations from 3 to 1 axis.
            %
            %   USAGE
            %       projectedVibrations = projectvibrations(vibrations,
            %           projectionType, projectionAxes)
            %
            %   INPUT PARAMETERS
            %       vibrations - Skin vibrations in 3 axes. Dimension of
            %           input should be (nTimesteps, nOutputLocations, 
            %           nAxes).
            %       projectionType - Type of projection to perform.
            %           'mag' - Magnitude of components.
            %           'pca' - Principal component analysis.
            %           'rms' - Project onto axis with the most energy.
            %           'soc' - Sum of components.
            %       projectionAxes - Axes to project onto. Must be 'x',
            %           'y', 'z', 'xy', 'xz', 'yz', or 'xyz'. 
            %
            %   OUTPUT PARAMETERS
            %       projectedVibrations - Skin vibrations projected onto
            %           1 axis. Size of output is (nTimesteps,
            %           nOutputLocations, 1).
            %       

            projectedVibrations = projectaxes(vibrations, ...
                projectionType, projectionAxes);
        end


        function [f, frequencyMagnitudeSpectrums] = ...
                getfrequencymagnitudespectrums(obj, vibrations)
            %
            % GETFREQUENCYMAGNITUDESPECTRUMS  calculates the single-sided
            %   frequency magnitude spectrums of given skin vibrations.
            %
            %   USAGE
            %       [f, frequencyMagnitudeSpectrums] =
            %           GETFREQUENCYMAGNITUDESPECTRUMS(vibrations)
            %
            %   INPUT PARAMETERS
            %       vibrations - Skin vibrations. Dimension of input should
            %           be (nTimesteps, nOutputLocations, nAxes).
            %
            %   OUTPUT PARAMETERS
            %       f - Frequencies (Hz).
            %       frequencyMagnitudeSpectrums - Single-sided frequency
            %           magnitude spectrums. Size of output is
            %           (ceil(nTimesteps/2), nOutputLocations, nAxes).
            %
            
            nTimesteps = size(vibrations, 1);
            nLocations = size(vibrations, 2);
            nAxes = size(vibrations, 3);

            if mod(nTimesteps, 2) == 0
                fftLen = nTimesteps/2 + 1;
            else
                fftLen = ceil(nTimesteps/2);
            end
            frequencyMagnitudeSpectrums = zeros(fftLen, ...
                nLocations, nAxes);
            for ii=1:nAxes
                [f, frequencyMagnitudeSpectrums(:, :, ii)] = ...
                    singlesidedfftmagnitudespectrums( ...
                        vibrations(:, :, ii), nTimesteps, ...
                        obj.constants.FS);
            end

        end


        function sinusoidStimuli = generatesinusoidinput(obj, ...
                signalLength, freqsHz, phaseRads, window)
            %
            % GENERATESINUSOIDINPUT  generates sinusoid inputs.
            %
            %   USAGE
            %       sinusoidStimuli = GENERATESINUSOIDINPUT(signalLength,
            %           freqsHz, phaseRads, window)
            %
            %   INPUT PARAMETERS
            %       signalLength - Length of the sinusoid(s) in samples.
            %       freqsHz - List of frequencies (Hz).
            %       phaseRads - List of phases (rad).
            %       window - Window to apply to the sinusoids. Can either
            %           be a vector (of length signalLength) or can specify
            %           a type of window: 'none', 'tukey', or 'hanning'.
            %
            %   OUTPUT PARAMETERS
            %       sinusoidStimuli - Cell array containing sinusoidal
            %           signals. Length of cell array should correspond to
            %           the number of desired input locations.
            %

            t = (0:signalLength-1)/obj.constants.FS;
            
            if ischar(window)         
                if strcmp(window, 'none')
                    window = ones(length(t), 1);
                elseif strcmp(window, 'tukey')
                    window = tukeywin(length(t), 0.25);
                elseif strcmp(window, 'hanning')
                    window = hanning(length(t));
                else
                    error("Window type not supported. Must be " + ...
                        "'none', 'tukey', or 'hanning', or provide" + ...
                        "your own window function.")
                end
            end

            sinusoidStimuli = getsinusoid(t, freqsHz, phaseRads, window);
        end


        function whiteNoiseStimuli = generatewhitenoise(obj, ...
                signalLength, nInputs, randomSeed)
            %
            % GENERATEWHITENOISE  generates white Gaussian noise inputs.
            %  
            %   USAGE
            %       whiteNoiseStimuli = GENERATEWHITENOISE(obj, 
            %           signalLength, nInputs, randomSeed)
            %
            %   INPUT PARAMETERS
            %       signalLength - Length of the stimulus (samples)
            %       nInputs - Number of inputs to generate.
            %       randomSeed - Random seed for the white noise
            %           generation. (Optional)
            %
            %   OUTPUT PARAMETERS
            %       whiteNoiseStimuli - White noise stimuli in a cell
            %           array. Number of cells corresponds to desired
            %           number of inputs.
            %

            if nargin == 4
                rng(randomSeed)
            end

            whiteNoiseStimuli = cell(1, nInputs);

            for ii=1:nInputs

                stimulus = randn(1, signalLength);

                % Bandpass the input signal within [25, 600] Hz to match
                % the frequency range of the impulse responses
                stimulus = highpass(stimulus, 25, obj.constants.FS);

                whiteNoiseStimuli{ii} = stimulus';

            end

        end


        function tapStimuli = generatetapinput(obj, nInputs, tapTimes)
            %
            % GENERATETAPINPUT  generates inputs approximating a tap.
            %   Taps are approximated as short hanning windows.
            %
            %   USAGE
            %       tapStimuli = generatetapinput(nInputs, tapTimes)
            %
            %   INPUT PARAMETERS
            %       nInputs - Number of input locations.
            %       tapTimes - Time (s) for each tap. 
            %
            %   OUTPUT PARAMETERS
            %       tapStimuli - Cell array of tap stimuli.
            %
            
            tap = hanning(21);  % approximation of a pulse

            tapStimuli = cell(1, nInputs);
            signalLength = round(max(tapTimes)*obj.constants.FS) + ...
                length(tap);

            for ii=1:nInputs
                stimulus = zeros(1, signalLength);
                midPoint = round(tapTimes(ii)*obj.constants.FS) + ...
                    ceil(length(tap)/2);
                startIdx = midPoint-floor(length(tap)/2);
                endIdx = midPoint+floor(length(tap)/2);
                stimulus(startIdx:endIdx) = tap;
                tapStimuli{ii} = stimulus';
            end
        end


    end

end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}