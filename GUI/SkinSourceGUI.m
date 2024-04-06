%% TODO
% Finishing touches aesthetically?
%   align text
%   move around a few boxes perhaps?
% Check save functionality

%% Figure initialization
figSize = [20,20,1800,750];
fig_h = figure('Name','NI Data Acquisition','Position',figSize,...
    'Color',[0.98,0.98,0.98]);
set(gcf, 'Color', 'w');
set(gcf,'Resize','off');
set(gcf, 'MenuBar', 'none'); 

%% Build blank skinsource objects as placeholders
Constants;
model = 1;
inputLocations = [1:20];
sigLength = 100; %in ms -> initial 
randomSeed = 0;
amplitudes = [zeros(20,1)];
interpolationType = 'natural';
visualizationAxes = 'z';
visualizationProjection = 'none';

skinsource = SkinSource(inputLocations, model, constants);
skinsourceVis = SkinSourceVisualization(inputLocations, model, ...
    constants);

inputStim = repmat({zeros(constants.FS,1)},1,20);

nSamps = floor(sigLength/1000*constants.FS);
truncatedInput = cellfun(@(x) x(1:nSamps), inputStim,'UniformOutput',false);

vibrations = skinsource.getoutputvibrations(truncatedInput, ...
    amplitudes);
projectedVibrations = skinsource.projectvibrations(vibrations, ...
    visualizationProjection, visualizationAxes);

% Plot the RMS amplitudes across the 2D surface
axHand = axes('Position',[0.38 0.07 0.52 0.52]); 
load('source/visualization/mask1.mat');
mask(~mask) = NaN;
imagesc(mask', 'AlphaData', ...
    ~isnan(mask)');
view(180,90);
set(gca, 'color', 'none')
axis equal
grid off
box off
axis off
cb = colorbar;
set(cb,'position',[.92 .1 .015 .3])

udata.input = inputStim;
udata.amplitudes = amplitudes;
udata.output = projectedVibrations;
udata.sigLength = sigLength; %initial signal length
udata.truncatedInput = truncatedInput;

fig_h.UserData = udata;

%% Input map image
axInput = axes('Position',[-0.07 0.15 0.7 0.7]); 
inputMap = imread('Documentation/inputLocations.png');
imshow(inputMap)

%% Input signal plot initialization
pltLoc = 0.9;
tArray = (0:(1*constants.FS)-1) / constants.FS; %always make 1 second signal, cut to length during render
for i = 1:20
    ax(i) = axes('Position',[0.08 pltLoc 0.1 0.038]); 
    pltLoc = pltLoc-0.043;

    tempPlt = cell2mat(inputStim(i));
    plot(tArray*1000,tempPlt,'k')
    
    if i ~= 20
        set(gca,'Xticklabel',[]) 
    else
        xlabel('Time (ms)');
    end
    set(gca,'Yticklabel',[]) 
    xlim([0 100]);
    grid off
    box off
    yticks([0]);
    yticklabels({i});
end

%% UI objects for signal length
%controls the input signal length
tControl = uicontrol('Style', 'edit',...
    'Position', [figSize(3) - 230 figSize(4)-112 100 30],...
    'BackgroundColor',[1,1,1],'FontSize',14, 'String', 100);

%label for input signal length
tControlLabel = uicontrol('Style', 'text',...
    'Position', [figSize(3) - 300 figSize(4)-82 250 30],...
    'BackgroundColor',[1,1,1],'String','Global Signal Length (ms)','FontSize',14);

%% UI objects for rendering

% Popup menu for selecting between models
modelObj = uicontrol('Style','popupmenu',...
    'Position', [figSize(3) - 735 figSize(4)-425 115 40],...
    'BackgroundColor', [1 1 1],...
    'String', {'Model 1','Model 2','Model 3','Model 4'},...
    'Tag','anchorMenu', 'FontSize',14);

%label for input signal length
axesLabel = uicontrol('Style', 'text',...
    'Position', [figSize(3) - 585 figSize(4)-398 70 40],...
    'BackgroundColor',[1,1,1],'String','Axis','FontSize',14);

% Popup menu for selecting between different axes to be rendered/visualized
axisObj = uicontrol('Style','popupmenu',...
    'Position', [figSize(3) - 582 figSize(4)-425 70 40],...
    'BackgroundColor', [1 1 1],...
    'String', {'x','y','z','xy','xyz'},...
    'Tag','anchorMenu', 'FontSize',14,'Value',3);


%label for input signal length
projLabel = uicontrol('Style', 'text',...
    'Position', [figSize(3) - 485 figSize(4)-398 90 40],...
    'BackgroundColor',[1,1,1],'String','Projection','FontSize',14);

% Popup menu for selecting between different methods of projecting multi-axis data
projObj = uicontrol('Style','popupmenu',...
    'Position', [figSize(3) - 480 figSize(4)-425 80 40],...
    'BackgroundColor', [1 1 1],...
    'String', {'none','mag','pca','rms','soc'},...
    'Tag','anchorMenu', 'FontSize',14);

% Button for rendering skinsource onto hand
renderButton = uicontrol('Style', 'pushbutton',...
    'Position', [figSize(3) - 325 figSize(4)-422 100 40],...
    'Callback', {@renderSkinSource, fig_h, axHand, modelObj, axisObj, projObj, constants, tControl, ax},...
    'BackgroundColor',[0.8,0.2,0.2],...
    'String','Render', 'Tag','rb', 'FontSize',14,'ForegroundColor','w');

% Button for saving rendered outputs
uicontrol('Style', 'pushbutton',...
    'Position', [figSize(3) - 200 figSize(4)-422 100 40],...
    'Callback', {@saveSkinsourceOutput, fig_h, modelObj, axisObj, projObj, constants},...
    'BackgroundColor',[0.2,0.2,0.8],...
    'String','Save', 'FontSize',14, 'ForegroundColor','w');

%% UI objects for signal generation
% Editable text box for input signal amplitude
aControl = uicontrol('Style', 'edit',...
    'Position', [figSize(3) - 500 figSize(4)-205 100 30],...
    'BackgroundColor',[1,1,1],'FontSize',14);

% Label for input signal amplitude
str = char(hex2dec('B2'));
aControlLabel = uicontrol('Style', 'text',...
    'Position', [figSize(3) - 660 figSize(4)-206 160 30],...
    'BackgroundColor',[1,1,1],'String', ['Amplitude (m/s',str,')'] ,'FontSize',14);

% Variable parameter which changes based on input signal type
fControl = uicontrol('Style', 'edit',...
    'Position', [figSize(3) - 500 figSize(4)-255 100 30],...
    'BackgroundColor',[1,1,1],'FontSize',14);

% Variable label which changes based on input signal type
fControlLabel = uicontrol('Style', 'text',...
    'Position', [figSize(3) - 650 figSize(4)-256 150 30],...
    'BackgroundColor',[1,1,1],'String','Frequency (Hz)','FontSize',14);

%popup menu for input signal types
sigTypeObj = uicontrol('Style','popupmenu',...
    'Position', [figSize(3) - 850 figSize(4)-250 125 30],...
    'Callback', {@changeSignalType, fig_h, fControlLabel, fControl},...
    'BackgroundColor', [1 1 1],...
    'String', {'Sinusoid', 'Impulse', 'Noise', 'Custom'},...
    'Tag','anchorMenu', 'FontSize', 14);

%label for input signal type
uicontrol('Style', 'text',...
    'Position', [figSize(3) - 980 figSize(4)-255 120 30],...
    'BackgroundColor',[1,1,1],...
    'String','Signal Type', 'FontSize',14);

% popup menu for holding input locations
locationCellArray = sprintfc('%i',1:20);
locationObj = uicontrol('Style','popupmenu',...
    'Position', [figSize(3) - 850 figSize(4)-205 100 30],...
    'BackgroundColor', [1 1 1],...
    'String', locationCellArray,...
    'Tag','anchorMenu', 'FontSize',14);

% label for input locations
uicontrol('Style', 'text',...
    'Position', [figSize(3) - 1000 figSize(4)-207 150 30],...
    'BackgroundColor',[1,1,1],...
    'String','Input Location', 'FontSize',14);

% section header
uicontrol('Style', 'text',...
    'Position', [figSize(3) - 700 figSize(4)-110 250 50],...
    'BackgroundColor',[1,1,1],...
    'String','Signal Generator', 'FontSize',20);

% assign signal to an input location
uicontrol('Style', 'pushbutton',...
    'Position', [figSize(3) - 310 figSize(4)-190 150 40],...
    'Callback', {@applySignal, fig_h, sigTypeObj, fControl, aControl, tControl, locationObj, ax, constants.FS},...
    'BackgroundColor',[0.8,0.8,0.8],...
    'String','Apply Signal', 'FontSize',14);

%clear signal button
uicontrol('Style', 'pushbutton',...
    'Position', [figSize(3) - 310 figSize(4)-240 150 40],...
    'Callback', {@clearSignal, fig_h, locationObj, ax, tControl, constants.FS},...
    'BackgroundColor',[0.8,0.8,0.8],...
    'String','Clear Signal', 'FontSize',14);

%clear all signals button
uicontrol('Style', 'pushbutton',...
    'Position', [figSize(3) - 310 figSize(4)-290 150 40],...
    'Callback', {@clearAllSignals, fig_h, ax, tControl, constants.FS},...
    'BackgroundColor',[0.8,0.8,0.8],...
    'String','Clear All Signals', 'FontSize',14);


%% MAIN LOOP
while ishandle(fig_h)
    pause(0.01)
end

%% CALLBACK FUNCTIONS
%apply an input signal
function applySignal(hObject, event, u, sigTypeObj, fObj, ampObj, tObj, loc, ax, fs)

    %initial common error checks
    [amp,ampFlag] = editableBoxToNum(ampObj);
    [sigLength, sigLenFlag] = editableBoxToNum(tObj);
    if ampFlag == 1
        fprintf('Error: Amplitude must be numerical.\n');
        return;
    elseif sigLenFlag == 1
        fprintf('Error: Signal length must be numerical.\n');
        return;
    elseif sigLength > 1000 || sigLength < 30
        fprintf('Error: Signal length must be between 30 and 1000 milliseconds.\n');
        return;
    end

    %make the input signal
    tArray = (0:(1*fs)-1) / fs; %always make 1 second signal, cut to length during render
    sigTypeIndex = get(sigTypeObj,'Value');
    switch sigTypeIndex
        
        %sinusoid
        case 1
            
            %grab frequency
            [sinFreq, freqFlag] = editableBoxToNum(fObj);

            if freqFlag == 1
                fprintf('Error: Frequency must be numerical.\n');
                return;
            elseif sinFreq < 25 || sinFreq > 600
                fprintf('Error: Frequency must be between 25 and 600 Hz.\n');
                return;
            end
            
            sig = sin(2*pi*sinFreq*tArray)';
            
        %Impulse
        case 2
            
            sig = zeros(length(tArray),1);
            sig(15) = 1;
            sig = sig ./ max(abs(sig));
            
        %Broandband Noise
        case 3
            
            %grab random seed
            [rngSeed, rngFlag] = editableBoxToNum(fObj);
            
            if rngFlag == 1
                fprintf('Error: Random number generator seed must must be numerical.\n');
                return;
            elseif rngSeed < 0 
                fprintf('Error: Random number generator seed must be non-negative.\n');
                return
            end
            
            rng(rngSeed);
            sig = randn(1, length(tArray));
            sig = highpass(sig, 25, fs);
            sig = sig' ./ max(abs(sig));
            
        %Custom
        case 4
            
            if isfile(fObj.String)
                [y,customFS] = audioread(fObj.String);
                if customFS ~= fs
                    fprintf('Error: Custom file sample rate is not 1300 Hz\n');
                    return
                end
            else
                fprintf('Error: Could not locate custom .wav file in filepath\n');
                return
            end
            
            %make 1300 samples
            nSamps = length(y);
            if nSamps > fs
                sig = y(1:fs);
            else
                sig = [y;zeros(fs - nSamps,1)];
            end       
            sig = sig ./ max(abs(sig));

    end

    cLoc = get(loc,'Value');
    udata = get(hObject.Parent,'UserData');
    udata.input(cLoc) = {sig};
    udata.amplitudes(cLoc) = amp;
    udata.sigLength = sigLength;
    set(hObject.Parent,'UserData',udata);
    plotInputSignals(udata.input,udata.amplitudes, ax, sigLength, fs);
    
end

%clear a single input signal
function clearSignal(hObject, event, u, loc, ax, tObj, fs)

    %initial common error checks
    [sigLength, sigLenFlag] = editableBoxToNum(tObj);
    if sigLenFlag == 1
        fprintf('Error: Signal length must be numerical.\n');
        return;
    elseif sigLength > 1000 || sigLength < 30
        fprintf('Error: Signal length must be between 30 and 1000 milliseconds.\n');
        return;
    end
    
    cLoc = get(loc,'Value');
    udata = get(hObject.Parent,'UserData');  
    udata.input(cLoc) = {zeros(fs,1)};
    udata.amplitudes(cLoc) = 0;
    udata.sigLength = sigLength;
    set(hObject.Parent,'UserData',udata);
    plotInputSignals(udata.input,udata.amplitudes,ax, sigLength, fs)

end


%clear all input signals
function clearAllSignals(hObject, event, u, ax, tObj, fs)

    %initial common error checks
    [sigLength, sigLenFlag] = editableBoxToNum(tObj);
    if sigLenFlag == 1
        fprintf('Error: Signal length must be numerical.\n');
        return;
    elseif sigLength > 1000 || sigLength < 30
        fprintf('Error: Signal length must be between 30 and 1000 milliseconds.\n');
        return;
    end

    udata = get(hObject.Parent,'UserData'); 
    udata.input = repmat({zeros(fs,1)},1,20);
    udata.amplitudes = zeros(20,1);
    udata.sigLength = sigLength;
    set(hObject.Parent,'UserData',udata);
    plotInputSignals(udata.input,udata.amplitudes,ax, sigLength, fs);
    
end

%change the UI controls for different signal types
function changeSignalType(hObject, event, u, fLabel, fObj)

    sigTypeIndex = get(hObject,'Value');
    switch sigTypeIndex
        
        %sinusoid
        case 1
            fLabel.Visible = 'on';
            fObj.Visible = 'on';
            fLabel.String = 'Frequency (Hz)';
            fObj.String = '';

        %impulse
        case 2
            fLabel.Visible = 'off';
            fObj.Visible = 'off';
    
        %noise
        case 3
            fLabel.Visible = 'on';
            fObj.Visible = 'on';
            fLabel.String = 'RNG Seed';
            fObj.String = '';
            
        %custom
        case 4
            fLabel.Visible = 'on';
            fObj.Visible = 'on';
            fLabel.String = 'Filename';
            fObj.String = '';            
    end

end

%render skinsource output
function renderSkinSource(hObject, event, u, axHand, modelObj, axisObj, projObj, constants, tObj, ax)

    %grab data for rendering
    udata = get(hObject.Parent,'UserData');
    
    
    %initial common error checks
    [sigLength, sigLenFlag] = editableBoxToNum(tObj);
    if sigLenFlag == 1
        fprintf('Error: Signal length must be numerical.\n');
        return;
    elseif sigLength > 1000 || sigLength < 30
        fprintf('Error: Signal length must be between 30 and 1000 milliseconds.\n');
        return;
    elseif ~(udata.sigLength == sigLength)
        udata.sigLength = sigLength;
        plotInputSignals(udata.input, udata.amplitudes, ax, sigLength, constants.FS);
    end
    inputStim = udata.input;
    
    %check inputs if non-zero
    renderFlag = 0;
    for i = 1:20
        temp = cell2mat(inputStim(i));
        if ~isempty(find(temp))
            renderFlag = 1;
            break;
        end
    end
    
    if renderFlag == 1
        
        inputLocations = [1:20];
        model = get(modelObj,'Value');
        interpolationType = 'natural';
        axesOptions = get(axisObj,'String');
        visualizationAxes = cell2mat(axesOptions(get(axisObj,'Value')));
        projOptions = get(projObj,'String');
        visualizationProjection = cell2mat(projOptions(get(projObj,'Value')));
        
        if length(visualizationAxes) > 1 && strcmp(visualizationProjection,'none')
            fprintf('Error: For visualization purposes please select a projection if multiple axes are requested.\n');
            return
        end

        skinsource = SkinSource(inputLocations, model, constants);
        skinsourceVis = SkinSourceVisualization(inputLocations, model, ...
            constants);

        
        nSamps = floor(sigLength/1000*constants.FS);
        truncatedInput = cellfun(@(x) x(1:nSamps), inputStim,'UniformOutput',false);
        
        vibrations = skinsource.getoutputvibrations(truncatedInput, ...
            udata.amplitudes);
        projectedVibrations = skinsource.projectvibrations(vibrations, ...
            visualizationProjection, visualizationAxes);
         
        set(gcf,'CurrentAxes',axHand);
        skinsourceVis.plotrmsvibrationsGUI(projectedVibrations, interpolationType)
        
        udata.truncatedInput = truncatedInput;
        udata.output = projectedVibrations;
    else
        fprintf('At least one input location must be non-zero.\n');
    end
    
    set(hObject.Parent,'UserData',udata);
    
end

%save the output
function saveSkinsourceOutput(hObject, event, u, modelObj, axisObj, projObj, constants)

    udata = get(hObject.Parent,'UserData');
    input = udata.truncatedInput;
    amplitudes = udata.amplitudes;
    output = udata.output;
    fs = constants.FS;
    
    renderingParameters.model = get(modelObj,'Value');
    renderingParameters.interpolationType = 'natural';
    
    %get axes
    axesOptions = get(axisObj,'String'); 
    renderingParameters.axes = cell2mat(axesOptions(get(axisObj,'Value')));

    %get projection
    projOptions = get(projObj,'String');
    renderingParameters.projection = cell2mat(projOptions(get(projObj,'Value')));
        
    save('SkinsourceGUI-Output.mat','input','output','amplitudes','fs','renderingParameters');

end

%% Utility functions

%grab numerical data from editable text box
function [val,flag] = editableBoxToNum(obj)
    strNum = obj.String;
    val = str2num(strNum);
    if isempty(val)
        flag = 1;
    else
        flag = 0;
    end
end

%plot input signals
function plotInputSignals(inputs, amps, ax, sigLength, fs)

    tArray = (0:(1*fs)-1) / fs; %always make 1 second signal, cut to length during render
    mVal = max(amps);
    if mVal == 0
        mVal = 1;
    end

    for i = 1:20
        set(gcf,'CurrentAxes',ax(i));
        tempPlt = cell2mat(inputs(i));
        plot(tArray*1000, tempPlt*amps(i),'k')
        
        if i ~= 20
            set(gca,'Xticklabel',[]) 
        else
            xlabel('Time (ms)');
        end
        ylim([-mVal, mVal]);
        xlim([0 sigLength]);
        set(gca,'Yticklabel',[]) 
        grid off
        box off
        yticks([0]);
        yticklabels({i});      
    end
    
end