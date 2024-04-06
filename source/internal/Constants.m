% CONSTANTS  Contains constants used in other files.
% It is not recommended to change these constants.

constants = {};

constants.N_AXES = 3; % Number of measurement axes (X, Y, Z)
constants.N_HAND_OUTPUT_LOCATIONS = 42;
constants.N_ARM_OUTPUT_LOCATIONS = 30;
constants.N_OUTPUT_LOCATIONS = constants.N_HAND_OUTPUT_LOCATIONS + ...
    constants.N_ARM_OUTPUT_LOCATIONS;
constants.FS = 1300; % Sample rate (Hz)

% Visualization
% Hand lengths of each participant in mm, ordered by participant number
constants.HAND_LENGTHS = [175, 165, 185, 165]; % P1, P2, P3, P4
% Length of the 2D hand surface in pixel space
constants.PIXEL_HAND_LENGTH = 398.1017;
constants.PIXEL_TO_MM_SCALE_FACTORS = ...
    constants.HAND_LENGTHS./constants.PIXEL_HAND_LENGTH;

% File path constants
constants.DATA_PATH = "dataset";
constants.IMPULSE_RESPONSE_PATH = ...
    sprintf('%s/impulseResponses.mat', constants.DATA_PATH);

constants.VISUALIZATION_PATH = "source/visualization/";
constants.ADJACENCY_MATRIX_PATH = strcat(constants.VISUALIZATION_PATH, ...
    "adjacencyMatrix.mat");
constants.OUTPUT_LOCATIONS_PATH = strcat(constants.VISUALIZATION_PATH, ...
    "outputLocations.mat");
constants.INPUT_LOCATIONS_PATH = strcat(constants.VISUALIZATION_PATH, ...
    "inputLocations.mat");
constants.SURFACE_PATH = strcat(constants.VISUALIZATION_PATH, ...
    "surface.mat");
constants.MASK_PATH = strcat(constants.VISUALIZATION_PATH, ...
    "mask");



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}