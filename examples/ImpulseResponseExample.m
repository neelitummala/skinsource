%
% IMPULSERESPONSEEXAMPLE is an example script for plotting the impulse
% responses across the dorsal surface of the upper limb. The given example
% corresponds to Fig. 1C in the paper.
%

close all
clear all
clc

% Load the constants struct
Constants

%% Parameters

% Upper limb model number (1-4)
model = 4;

% Input location (1-20)
inputLocation = 8;

% For visualization:
% Type of interpolation to use
interpolationType = 'natural';

% Axis to visualize the vibrations on
visualizationAxes = 'z';

% Method to project the data from 3 axes to 1 axis
visualizationProjection = 'none';

%% Determine the skin vibrations in response to the sinusoidal inputs

% Initialize a SkinSource object to get output vibrations across the upper
% limb for given parameters
skinsource = SkinSource(inputLocation, model, constants);

% Initialize a SkinSourceVisualization object to do some plotting
skinsourceVis = SkinSourceVisualization(inputLocation, model, ...
    constants);

% Get the impulse responses corresponding to the upper limb model and input
% location
impulseResponses = selectimpulseresponses(skinsource.impulseResponses, ...
    model, inputLocation);

% Project the vibrations onto the desired axes with the desired
% projection method. In this case, we are looking at only the z axis.
projectedVibrations = skinsource.projectvibrations(impulseResponses, ...
    visualizationProjection, visualizationAxes);

% Plot the time-domain vibrations at selected points
selectedLocations = [20, 24, 26, 27, 48, 49, 72];
skinsourceVis.plotselectedtimedomainvibrations(projectedVibrations, ...
    selectedLocations, 0);

% Plot the magnitude (across axes) of skin vibrations across the upper limb 
% at selected time steps
timesteps = linspace(0.052, 0.055, 5); % in seconds
projectedVibrations = skinsource.projectvibrations(impulseResponses, ...
    'mag', 'xyz');
skinsourceVis.plottimestepvibrations(projectedVibrations, timesteps, ...
    interpolationType, 1)


% Revision history:
%{
2024-04-05: v1.0.0 released.
%}