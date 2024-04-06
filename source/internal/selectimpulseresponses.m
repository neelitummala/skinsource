function selectedImpulseResponses = ...
    selectimpulseresponses(impulseResponses, model, location)
    %
    % SELECTEDIMPULSERESPONSES  selects impulse responses from the data
    %   table that correspond to a given upper limb model and input 
    %   location.
    %
    %   USAGE
    %       selectedImpulseResponses =
    %           SELECTEDIMPULSERESPONSES(impulseResponses, model,
    %           location)
    %
    %   INPUT PARAMETERS
    %       impulseResponses - Data table with impulse responses for all
    %           upper limb models and input locations.
    %       model - Upper limb model number. Must be within [1, 4].
    %       location - Input location. Must be within [1, 20].
    %
    %   OUTPUT PARAMETERS
    %       selectedImpulseResponses - Matrix of impulse responses
    %           corresponding to given upper limb model and input location.
    %           Should be of dimensions (nTimesteps, nOutputLocations,
    %           nAxes).
    %
    
    modelFlags = impulseResponses.Model == model;
    selectedTable = impulseResponses(modelFlags, :);
    locationFlags = selectedTable.Location == location;
    selectedTable = selectedTable(locationFlags, :);
    selectedImpulseResponses = selectedTable.Data{1};
    
end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}