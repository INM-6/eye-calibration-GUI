function varargout = EyeCalib(varargin)
% EYECALIB MATLAB code for EyeCalib.fig
%      EYECALIB, by itself, creates a new EYECALIB or raises the existing
%      singleton*.
%
%      H = EYECALIB returns the handle to a new EYECALIB or the handle to
%      the existing singleton*.
%
%       EyeCalib opens the menu for calibration recordings treatment to
%       define the parameter of the 2D polynomial function that should be
%       used to convert Eyelink output into a gaze position signal in the
%       hand/stimulus plane.
%
%       Calibration needs two files from cerebus (a .NEV file with events
%       and codes and a .NSx file with analog signals) or a c3d file from
%       Dexterit-E. When the user clicks on the [LOAD NEV/NSx] button, an
%       explorer window opens and allows to select the files.
%
%       Once loaded, the informations are reorganized in a structure named
%       calibData that contains all data sorted by target, and for each
%       target, sorted by trial. For each trial, a flag define if the trial
%       should be kept or removed in the next steps. It is possible to
%       export this structure as a .mat file with the button [EXPORT].
%
%       It is also possible to load a previously saved structure by
%       clicking on the [IMPORT] button.
%
%       After you put data in memory, either from a .mat file, .c3d or a
%       .NEV/.NSx file couple, you can start the calibration. First step is
%       trace selection where you will determine if some trials need to be
%       rejected because of an unwanted eye movement, or because of a bad
%       signal to noise ratio.
%       You can do this on signals from both X and Y channels with a click
%       on [X TRACES SELECT] or [Y TRACES SELECT] respectively. A click on
%       one of these buttons opens a new window. See CalibStep1.m help for
%       detailed informations.
%
%       After trial selection is complete, you will run the fitting tool to
%       adjust the best 2D polynomial function to your data. To do this,
%       you will click on the [FIT FUNCTIONS] button. It will open a new
%       window. See CalibStep2D.m help for detailed informations.
%
%       When the procedure is achieved, you can save the polynomial
%       function parameters in a .dtp file to use them in Dexterit-e with a
%       click on [Save to Dexterit-E] button. See save2dtp.m help for more
%       details.
%
%       Dependencies.
%       - EyeCalib :
%                   - .\Images\Ju logo.PNG
%                   - .\Images\logoINT.jpg
%                   - .\NPMK\openNEV
%                   - .\NPMK\openNSx
%                   - TargetStructureFilling :
%                                   - All NPMK package from Blackrock
%                   - TargetStructureFilling_c3d :
%                                   - All C3D_load_v2.14 from B-kin
%                   - CalibStep1 :
%                                   - ZoomTarget
%                   - CalibStep2D :
%                                   - polyfitweighted2
%                                   - polyval2
%                   - save2dtp
%
%
% Last Modified by FVB 23-Dec-2014 14:34:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @EyeCalib_OpeningFcn, ...
    'gui_OutputFcn',  @EyeCalib_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before EyeCalib is made visible.
function EyeCalib_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EyeCalib (see VARARGIN)
% Choose default command line output for EyeCalib


% Image reading for "ForschungsZentrum Juelich" and "Institut de Neuro-
% sciences de la Timone" logo
juelichImage =imread('Images\Ju logo.PNG');
INTImage =imread('Images\logoINT.jpg');
% Switch active axes to the one you made for the image and put the image
% into the axes so it will appear in the GUI
axes(handles.axes1);
image(juelichImage);
axis off
axes(handles.axes2);
image(INTImage);
axis off
eyeCalibFilename = which('EyeCalib');
setappdata(gcf,'eye_calib_folder',eyeCalibFilename(1:end-10));
setappdata(gcf,'pref',load([getappdata(gcf,'eye_calib_folder') 'Preferences.mat']));
setappdata(gcf,'calibData',[]);
%Actualise the HANDLE
guidata(hObject, handles);
%clc;
%clear all;


% --- Outputs from this function are returned to the command line.
function varargout = EyeCalib_OutputFcn(hObject, ~, ~)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = hObject;

% --- Executes on button press in loadData.
function loadData_Callback(~, ~, ~)
% hObject    handle to loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Define the start folder for uigetfile according to user preferences
pref = getappdata(gcf,'pref');
tmp_calibData = getappdata(gcf,'calibData');
% open a c3dfile or a NEV file and get its name
DialogTitle= 'Open NEV or c3d (zip)';
[filename, pathname] = uigetfile(fullfile(pref.default_dext_data_path,'\','*.nev;*.zip'),DialogTitle);
if filename ~= 0
    % gets the extension of the file
    [~,~,ext] = fileparts(filename);
    if strcmp(ext,'.zip')% if the file is a zip
        tmp_calibData = TargetStructureFilling_c3d(pathname, filename);
        
        % Check which eye is present in the datafile
        if isfield(tmp_calibData.targetData(1).eyeDataLeft,'eyeXVolt') && ...
                isfield(tmp_calibData.targetData(1).eyeDataRight,'eyeXVolt')
            % ask which eye to calibrate and save it into eyeSelection
            tmp_calibData.setupData.eyeSelection = questdlg(...
                'Which eye do you want to calibrate ?',...
                'Eye ' ,...
                'Left','Right','Right');
            % or if there is no choice, just inform the user of the eye found
        elseif isfield(tmp_calibData.targetData(1).eyeDataLeft,'eyeXVolt')
            msgbox({'Data found for Left Eye only';'Calibrating Left eye'});
            tmp_calibData.setupData.eyeSelection = 'Left';
        elseif isfield(tmp_calibData.targetData(1).eyeDataRight,'eyeXVolt')
            msgbox({'Data found for Right Eye only';'Calibrating Right eye'});
            tmp_calibData.setupData.eyeSelection = 'Right';
        else % If no eye is found, alert the user about the situation
            warndlg('Oops! This datafile seems to contain no data.');
        end
        
        % if the file is a nev file
    elseif strcmp(ext,'.nev')
        % Call openNEV and openNSx function to get the NEV and NSx into mat
        NEV = openNEV(filename,'overwrite');
        NSx = openNSx('read');
        % Organise all the data from .NEV and .NSx files in the structure
        % calibData
        tmp_calibData = TargetStructureFilling(NEV,NSx);
        tmp_calibData.setupData.eyeSelection = 'Undefined';
    else
        disp('Error: wrong file type');
    end
end
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
setappdata(eyeCalibObjID,'calibData',tmp_calibData)


% --- Executes on button press in trialSelectX.
function trialSelectX_Callback(~, ~, ~)
%This function calls the figure CalibStep1 which displays the traces of eye
% position for the different trials and the different targets.
% CalibStep1 must be called with a parameter that defines the channel 'X'
% or 'Y'.
%global calibData;
tmp_calibData = getappdata(gcf,'calibData');

%If the data are empty, alert the user and quit the function
if isempty(tmp_calibData)
    msgbox('Error : Calibration Data not found');
    return;
end

% Each trial's flag is copied in the calibData structure into a temp flag.
% When something changes in the flag configuration in the CalibStep1 and
% ZoomTarget figure, only the temp flag is affected. This allows to know if
% the user made modifications during the previous figure. The original flag
% is only modified by a press on a button (see help in CalibStep1)
switch tmp_calibData.setupData.eyeSelection
    case 'Right'
        for targetNum = 1:tmp_calibData.setupData.targetNum
            for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
                tmp_calibData.targetData(targetNum).eyeDataRight(trialIndex).flagTemp = tmp_calibData.targetData(targetNum).eyeDataRight(trialIndex).flag;
            end
        end
    case 'Left'
        for targetNum = 1:tmp_calibData.setupData.targetNum
            for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
                tmp_calibData.targetData(targetNum).eyeDataLeft(trialIndex).flagTemp = tmp_calibData.targetData(targetNum).eyeDataLeft(trialIndex).flag;
            end
        end
    case 'Undefined'
        for targetNum = 1:tmp_calibData.setupData.targetNum
            for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
                tmp_calibData.targetData(targetNum).eyeData(trialIndex).flagTemp = tmp_calibData.targetData(targetNum).eyeData(trialIndex).flag;
            end
        end
    otherwise
        errordlg('Error : Calibration Data not found');
        return;
        
end
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
setappdata(eyeCalibObjID,'calibData',tmp_calibData)
%Call of CalibStep1 figure
CalibStep1('X');

% --- Executes on button press in trialSelectY.
function trialSelectY_Callback(~, ~, ~)
%This function calls the figure CalibStep1 which displays the traces of eye
% position for the different trials and the different targets.
% CalibStep1 must be called with a parameter that defines the channel 'X'
% or 'Y'.
%global calibData;
tmp_calibData = getappdata(gcf,'calibData');

%If the data are empty, alert the user and quit the function

if isempty(tmp_calibData)
    msgbox('Error : Calibration Data not found');
    return;
end

% Each trial's flag is copied in the calibData structure into a temp flag.
% When something changes in the flag configuration in the CalibStep1 and
% ZoomTarget figure, only the temp flag is affected. This allows to know if
% the user made modifications during the previous figure. The original flag
% is only modified by a press on a button (see help in CalibStep1)
switch tmp_calibData.setupData.eyeSelection
    case 'Right'
        for targetNum = 1:tmp_calibData.setupData.targetNum
            for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
                tmp_calibData.targetData(targetNum).eyeDataRight(trialIndex).flagTemp = tmp_calibData.targetData(targetNum).eyeDataRight(trialIndex).flag;
            end
        end
    case 'Left'
        for targetNum = 1:tmp_calibData.setupData.targetNum
            for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
                tmp_calibData.targetData(targetNum).eyeDataLeft(trialIndex).flagTemp = tmp_calibData.targetData(targetNum).eyeDataLeft(trialIndex).flag;
            end
        end
    case 'Undefined'
        for targetNum = 1:tmp_calibData.setupData.targetNum
            for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
                tmp_calibData.targetData(targetNum).eyeData(trialIndex).flagTemp = tmp_calibData.targetData(targetNum).eyeData(trialIndex).flag;
            end
        end
    otherwise
        msgbox('Error : Calibration Data not found');
        return;
        
end
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
setappdata(eyeCalibObjID,'calibData',tmp_calibData)
%Call of CalibStep1 figure
CalibStep1('Y');

% --- Executes on button press in fitFunctions.
function fitFunctions_Callback(hObject, ~, handles)
%This function call the figure CalibStep2D which calculates and
%returns the parameters for Dexterit-E

%global calibData;
tmp_calibData = getappdata(gcf,'calibData');

%If the data are empty, alert the user and quit the function
if isempty(tmp_calibData)
    msgbox('Error : Calibration Data not found');
    return;
end

% Actualise the handle
guidata(hObject, handles);

%Call CalibStep2D figure
CalibStep2D();

% --- Executes on button press in saveData.
function saveData_Callback(~, ~, ~)
%returns the parameters to Dexterit-E writing in the chosen DTP file.
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
savedfitXfunction.coef = getappdata(eyeCalibObjID,'savedfitXfunction');
savedfitYfunction.coef = getappdata(eyeCalibObjID,'savedfitYfunction');
% Parameter list generation
% 1) Calibration model parameters
% Add a title for each parameter and put them into an array 'parameter'
letterList = ['A'
    'B'
    'C'
    'D'
    'E'
    'F'
    'G'
    'H'
    'I'
    'J'
    'K'
    'L'
    'M'
    'N'
    'O'];
for i=1:1:15
    parameter(i).title = ['Xcoef' letterList(i)];
    parameter(i).value = savedfitXfunction.coef{i};
    parameter(i + 15).title = ['Ycoef' letterList(i)];
    parameter(i + 15).value = savedfitYfunction.coef{i};
end
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
setappdata(eyeCalibObjID,'model_parameters',parameter)
% 2) Mean voltage recorded when the subject looked at the central
% target on X and Y channels. We can find the values in gridData that
% contains mean voltages for all the targets.
% Remind: We need 4 coordinates in gridData (MxNxPxQ matrix) that are:
% X rank of the target (3,-,-,- because central target is on third column)
% Y rank of the target (-,3,-,- because central target is on third row)
% Voltages are on coordinate 2 for P (-,-,2,-)
% X and Y voltages are at coordinates 1 and 2 respectively for Q
% (-,-,-,1) and (-,-,-,2)



% THESE PARAMETERS ARE THERE TO KEEP A TRACE OF THE CENTRAL TARGET VOLTAGE
% IN CASE OF A DRIFT CORRECTION. SHOULD BE MODIFIED IF DRIFT CORRECTION IS
% USED.
parameter(31).title = 'XvoltsCenter';
parameter(31).value = 0;
parameter(32).title = 'YvoltsCenter';
parameter(32).value = 0;



%Call save2dtp function (write on the correct line in the DTP file even with dynamic values)
% Call dtp selection window (optimized for saving in multiple dtp at once)
select_dtp(parameter);

% Saves the parameters in a matfile in the metadata directory.
FileName = 'Calibparameter.mat';
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
if ~isempty(eyeCalibObjID)
    handles.pref = getappdata(eyeCalibObjID,'pref');
    PathName = handles.pref.default_metadata_path;
else
    disp('Error in the path: No EyeCalibWindow object found')
    return
end
save('-mat',[PathName '\' FileName],'parameter');
disp('Parameters Saved');

if handles.pref.always_mat_chk == 1
    exportButton_Callback(handles);
end



% --- Executes on button press in quitGeneral.
function quitGeneral_Callback(~, ~, ~)
% hObject    handle to quitGeneral (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;

% --- Executes on button press in exportButton.
function exportButton_Callback(~, ~, ~)
% Save all the calibData structure in a MAT file.
%Allows to reload it with importButton function

eyeCalibObjID = findobj('Tag','EyeCalibWindow');
tmp_calibData = getappdata(eyeCalibObjID,'calibData');
try
    %if calibData is empty, alert the user with a messageBox and exit the
    %function
    if isempty(tmp_calibData)
        msgbox('Error : Calibration Data not found');
        return;
    end
    %Save the parameters in a .MAT file (in the metadata directory)
    
    
    FileName = 'Calibdata.mat';

eyeCalibObjID = findobj('Tag','EyeCalibWindow');
if ~isempty(eyeCalibObjID)
    handles.pref = getappdata(eyeCalibObjID,'pref');
    PathName = handles.pref.default_metadata_path;
else
    disp('Error in the path: No EyeCalibWindow object found')
    return
end

%    [FileName,PathName] = uiputfile('.mat','exportData','tmp_calibData');
    save('-mat',[PathName '\' FileName],'tmp_calibData');
    disp('Export to mat complete');
catch
    disp('Export issue');
end

% --- Executes on button press in importButton.
function importButton_Callback(~, ~, ~)
% Load the .MAT file and put it into the calibData structure

%global calibData;
tmp_calibData = getappdata(gcf,'calibData');

try
    [fileName, pathName] = uigetfile('*.mat', 'Choose a MAT file...');
    loadedData = load([pathName fileName],'-mat');
    tmp_calibData = loadedData.calibData;
catch
    disp('Import issue');
end
setappdata(gcf,'calibData',tmp_calibData);

% --- Executes on button press in preferences_button.
function preferences_button_Callback(~, ~, ~)
% hObject    handle to preferences_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setpref();


