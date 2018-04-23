function varargout = ZoomTarget(varargin)
% ZOOMTARGET MATLAB code for ZoomTarget.fig
%      ZOOMTARGET, by itself, creates a new ZOOMTARGET or raises the existing
%      singleton*.
%
%      H = ZOOMTARGET returns the handle to a new ZOOMTARGET or the handle to
%      the existing singleton*.
%
%      ZOOMTARGET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZOOMTARGET.M with the given input arguments.
%
%      ZOOMTARGET('Property','Value',...) creates a new ZOOMTARGET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ZoomTarget_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ZoomTarget_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ZoomTarget

% Last Modified by GUIDE v2.5 10-Jun-2014 11:47:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ZoomTarget_OpeningFcn, ...
    'gui_OutputFcn',  @ZoomTarget_OutputFcn, ...
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

% --- Executes just before ZoomTarget is made visible.
function ZoomTarget_OpeningFcn(openhObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ZoomTarget (see VARARGIN)

% Choose default command line output for ZoomTarget
handles.output = openhObject;
%global calibData;
targetNum = varargin{1};
handles.tn = targetNum;
handles.current_axe = varargin{2};

set(gca,'color',[10/255 36/255 106/255]);

eyeCalibObjID = findobj('Tag','EyeCalibWindow');
handles.calibData = getappdata(eyeCalibObjID,'calibData');

% Update handles structure
guidata(openhObject, handles);

% Update Axes
update_axes(targetNum, handles);
% UIWAIT makes ZoomTarget wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function LineSelected(linehObject, eventdata, trialObject, target_num)
%change the color if the trial is flagged or not
global testValue;
testValue = get(linehObject,'YData');
set(linehObject, 'color','g');
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
calibData = getappdata(eyeCalibObjID,'calibData');
if strcmp(calibData.setupData.eyeSelection,'Right')
    for trialIndex = find(trialObject ~= linehObject)
        if calibData.targetData(target_num).eyeDataRight(trialIndex).flagTemp == 1
            set(trialObject(trialIndex), 'color','w');
        else
            set(trialObject(trialIndex), 'color','r');
        end
    end
else
    for trialIndex = find(trialObject ~= linehObject)
        if calibData.targetData(target_num).eyeDataLeft(trialIndex).flagTemp == 1
            set(trialObject(trialIndex), 'color','w');
        else
            set(trialObject(trialIndex), 'color','r');
        end
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = ZoomTarget_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
%varargout{1} = handles.output;

% --- Executes on button press in flagButton.
function flagButton_Callback(flaghObject, eventdata, handles)
%flag the trial if it is selected and the button pressed

global testValue;
%get the current target 
targetNum = handles.tn;
if strcmp(handles.calibData.setupData.eyeSelection,'Right')
    for trialIndex = 1:handles.calibData.targetData(targetNum).nbTrial
        if strcmp(handles.current_axe,'X')
            %if the one selected has the same values than the value in the
            %calibData structure, then the trial is flagged
%             size_test = size(testValue);
%             trialindexFB = trialIndex;
%             size_trial = size(handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeXVolt);
            if handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeXVolt == testValue
                handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).flagTemp = 0;
            end
        else
            %if the one selected has the same values than the value in the
            %calibData structure, then the trial is flagged
            if handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeYVolt == testValue
                handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).flagTemp = 0;
            end
        end
    end
    
else
    for trialIndex = 1:handles.calibData.targetData(targetNum).nbTrial
        if strcmp(handles.current_axe,'X')
            %if the one selected has the same values than the value in the
            %calibData structure, then the trial is flagged
            testValue;
            handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeXVolt
            if handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeXVolt == testValue
                handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).flagTemp = 0;
            end
        else
            %if the one selected has the same values than the value in the
            %calibData structure, then the trial is flagged
            if handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeYVolt == testValue
                handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).flagTemp = 0;
            end
        end
    end
end

hold off
% Update handles structure
guidata(flaghObject, handles);
%change the color in the gui
update_axes(targetNum, handles);

% --- Executes on button press in unflagButton.
function unflagButton_Callback(unflaghObject, eventdata, handles)
%flag the trial if it is selected and the button pressed,
%the code is the same as the flagButton function

global testValue;

targetNum = handles.tn;
if strcmp(handles.calibData.setupData.eyeSelection,'Right')
    for trialIndex = 1:handles.calibData.targetData(targetNum).nbTrial
        if strcmp(handles.current_axe,'X')
            if handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeXVolt == testValue
                handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).flagTemp = 1;
            end
        else
            if handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeYVolt == testValue
                handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).flagTemp = 1;
            end
        end
    end
else
    for trialIndex = 1:handles.calibData.targetData(targetNum).nbTrial
        if strcmp(handles.current_axe,'X')
            if handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeXVolt == testValue
                handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).flagTemp = 1;
            end
        else
            if handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeYVolt == testValue
                handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).flagTemp = 1;
            end
        end
    end
end
hold off
% Update handles structure
guidata(unflaghObject, handles);
update_axes(targetNum, handles);

function update_axes(targetNum, handles)
% Update Axes
BGcolor = get(gca,'Color');
Xcolor  = get(gca, 'Xcolor');
Ycolor = get(gca, 'Ycolor');
GridX = get(gca, 'XGrid');
GridY = get(gca, 'YGrid');
axes(handles.axesZoom);

%newplot(handles.axesZoom);
if strcmp(handles.calibData.setupData.eyeSelection,'Right')
    for trialIndex = 1:handles.calibData.targetData(targetNum).nbTrial
        if handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).flagTemp == 1
            
            if strcmp(handles.current_axe,'X')
                trialObject(trialIndex) = plot(1:length(handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeXVolt),handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeXVolt,'w-');
            else
                trialObject(trialIndex) = plot(1:length(handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeYVolt),handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeYVolt,'w-');
            end
            hold on
        else
            if strcmp(handles.current_axe,'X')
                trialObject(trialIndex) = plot(1:length(handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeXVolt),handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeXVolt,'r-');
            else
                trialObject(trialIndex) = plot(1:length(handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeYVolt),handles.calibData.targetData(targetNum).eyeDataRight(trialIndex).eyeYVolt,'r-');
            end
            hold on
        end
    end
else
    for trialIndex = 1:handles.calibData.targetData(targetNum).nbTrial
        if handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).flagTemp == 1
            
            if strcmp(handles.current_axe,'X')
                trialObject(trialIndex) = plot(1:length(handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeXVolt),handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeXVolt,'w-');
            else
                trialObject(trialIndex) = plot(1:length(handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeYVolt),handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeYVolt,'w-');
            end
            hold on
        else
            if strcmp(handles.current_axe,'X')
                trialObject(trialIndex) = plot(1:length(handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeXVolt),handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeXVolt,'r-');
            else
                trialObject(trialIndex) = plot(1:length(handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeYVolt),handles.calibData.targetData(targetNum).eyeDataLeft(trialIndex).eyeYVolt,'r-');
            end
            hold on
        end
    end
end

set(trialObject, 'ButtonDownFcn', {@LineSelected, trialObject, targetNum});
set(gca,'Color', BGcolor);
set(gca,'XColor', Xcolor);
set(gca,'YColor', Ycolor);
set(gca, 'XGrid', GridX);
set(gca, 'YGrid', GridY);

% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, handles)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Calls the Calib step 1 function to update axes
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
setappdata(eyeCalibObjID,'calibData',handles.calibData);
close;
CalibStep1(handles.current_axe);

% --- Executes on mouse press over axes background.
function axesZoom_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
