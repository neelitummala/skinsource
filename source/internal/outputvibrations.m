function outputVibrations = outputvibrations(inputStimuli, amplitudes, ...
    inputLocations, impulseResponses, model)
%
% OUTPUTVIBRATIONS  Returns reconstructed output skin vibrations
%   given one or more input stimuli and one or more sets of impulse 
%   responses. If more than one input stimulus and set of impulse responses
%   is provided, the resulting vibrations will be summed together
%   (superposition).
%
%   USAGE
%       outputVibrations = OUTPUTVIBRATIONS(inputStimuli, 
%           impulseResponses)
%
%   INPUT PARAMETERS
%       inputStimuli - Cell array of input stimuli.
%       amplitudes - Desired maximum peak-to-peak accelerations 
%           (m/s^2) across the upper limb for output skin vibrations 
%           resulting from the application of each of the input stimuli.
%       inputLocations - Input locations for each of the input stimuli.
%       impulseResponses - Cell array containing 2D matrices of impulse 
%           responses. Each row is an impulse response, each column is a
%           timestep.
%       model - Upper limb model number.
%
%   OUTPUT PARAMETERS
%       outputVibrations - 2D matrix of output skin vibrations. Each row is
%           an output location and each column is a timestep.
%

    nLocs = length(inputLocations);
    nStimuli = length(inputStimuli);

    % Check that the number of input locations matches the number of
    % stimuli provided
    if (nLocs ~= nStimuli)
        error(strcat('Need to supply the same number of stimuli, ', ...
            'and locations.'));
    end

    % Check that all stimuli have the same length
    stimulusLengths = zeros(1, nStimuli);
    for ii=1:nStimuli
        stimulusLengths(ii) = length(inputStimuli{ii});
    end
    if sum(diff(stimulusLengths)) ~= 0
        error('Need to supply stimuli that are all the same length.')
    end

    outputVibrations = ...
        zeros(size(impulseResponses.Data{1}, 1) + ...
          length(inputStimuli{1}) - 1, ...
          size(impulseResponses.Data{1}, 2), ...
          size(impulseResponses.Data{1}, 3));

    % Iterate through input locations/stimuli
    for ii=1:nLocs
        inputStimulus = inputStimuli{ii};
        inputLocation = inputLocations(ii);

        % Select impulse responses corresponding to desired upper 
        % limb model and input location
        impulseResponses_ii = selectimpulseresponses(impulseResponses, ...
            model, inputLocation);

        outputVibrations_ii = zeros(size(impulseResponses_ii, 1) + ...
            length(inputStimulus) - 1, size(impulseResponses_ii, 2), ...
            size(impulseResponses_ii, 3));

        % Get output vibrations using convolution
        for ax=1:size(impulseResponses_ii, 3)
            outputVibrations_ii(:, :, ax) = ...
                conv2(impulseResponses_ii(:, :, ax), ...
                inputStimulus, 'full');
        end 

        % Scale resulting vibrations by maximum peak-to-peak vibration on
        % the surface to match desired amplitude.
        scaleFactor = max(outputVibrations_ii, [], 'all', 'omitnan');
        
        % Error check if zero input
        if scaleFactor == 0
            scaleFactor = 1;
        end
        
        outputVibrations_ii = amplitudes(ii)*outputVibrations_ii / ...
            scaleFactor;

        % Superposition (if there is more than one input location)
        outputVibrations = outputVibrations + outputVibrations_ii;
    end

end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}