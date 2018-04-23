function varargout = CalibStep2D(varargin)
% CALIBSTEP2D M-file for CalibStep2D.fig
%      CALIBSTEP2D, by itself, creates a new CALIBSTEP2D or raises the existing
%      singleton*.
%
%      H = CALIBSTEP2D returns the handle to a new CALIBSTEP2D or the handle to
%      the existing singleton*.
%
%      CALIBSTEP2D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBSTEP2D.M with the given input arguments.
%
%      CALIBSTEP2D('Property','Value',...) creates a new CALIBSTEP2D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CalibStep2D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CalibStep2D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
%       CalibStep2D apply the polynnomial fit on the data outputed by
%       CalibStep1.
% Last Modified by FVB 07-Jan-2015 15:40:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CalibStep2D_OpeningFcn, ...
    'gui_OutputFcn',  @CalibStep2D_OutputFcn, ...
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


% --- Executes just before CalibStep2D is made visible.
function CalibStep2D_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CalibStep2D (see VARARGIN)


eyeCalibObjID = findobj('Tag','EyeCalibWindow');
tmp_calibData = getappdata(eyeCalibObjID,'calibData');

% Initialization of needed constant
handles.saveStatus = 0; % To ask confirmation from the user in case of unsed changes when he leaves
handles.select_2_status = 1;
handles.select_3_status = 0;
handles.select_4_status = 0;
handles.model_order = 2;

% Grid data matrix
% (targetID, info, channel)
% info :    1 = target (cm)
%           2 = eye mean pos (V)
%           3 = eye std
%           4 = corrected pos (cm)
handles.gridData = zeros(size(tmp_calibData.targetData,2),3,2);

if strcmp(tmp_calibData.setupData.eyeSelection,'Right')
    % average calculation for each target
    
    for targetIndex = 1:1:size(tmp_calibData.targetData,2)
        stdXvector = [];
        stdYvector = [];
        % We take all the trials...
        for trialIndex = 1:1:tmp_calibData.targetData(targetIndex).nbTrial
            handles.gridData(targetIndex,1,1) = tmp_calibData.targetData(targetIndex).targetXpos;
            handles.gridData(targetIndex,1,2) = tmp_calibData.targetData(targetIndex).targetYpos;
            % Wich were not flagged in calibStep1
            if tmp_calibData.targetData(targetIndex).eyeDataRight(trialIndex).flag == 1
                % And we sum all the samples
                handles.gridData(targetIndex,2,1) = handles.gridData(targetIndex,2,1) + sum(tmp_calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeXVolt);
                handles.gridData(targetIndex,2,2) = handles.gridData(targetIndex,2,2) + sum(tmp_calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeYVolt);
                %std
                stdXvector = cat(2,stdXvector,(tmp_calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeXVolt));
                stdYvector = cat(2,stdYvector,(tmp_calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeYVolt));
            end
        end
        % Then we get the mean by dividing by the number of samples (ie. number
        % of trials left times trial length
        handles.gridData(targetIndex,2,1) = handles.gridData(targetIndex,2,1)./(sum([tmp_calibData.targetData(targetIndex).eyeDataRight.flag]).*length(tmp_calibData.targetData(targetIndex).eyeDataRight(1).eyeXVolt));
        handles.gridData(targetIndex,2,2) = handles.gridData(targetIndex,2,2)./(sum([tmp_calibData.targetData(targetIndex).eyeDataRight.flag]).*length(tmp_calibData.targetData(targetIndex).eyeDataRight(1).eyeYVolt));
        % We also compute the standard deviation
        handles.gridData(targetIndex,3,1) = std(stdXvector); %std X
        handles.gridData(targetIndex,3,2) = std(stdYvector); %std Y
    end
else
    for targetIndex = 1:1:size(tmp_calibData.targetData,2)
        stdXvector = [];
        stdYvector = [];
        % We take all the trials...
        for trialIndex = 1:1:tmp_calibData.targetData(targetIndex).nbTrial
            handles.gridData(targetIndex,1,1) = tmp_calibData.targetData(targetIndex).targetXpos;
            handles.gridData(targetIndex,1,2) = tmp_calibData.targetData(targetIndex).targetYpos;
            % Wich were not flagged in calibStep1
            if tmp_calibData.targetData(targetIndex).eyeDataLeft(trialIndex).flag == 1
                % And we sum all the samples
                handles.gridData(targetIndex,2,1) = handles.gridData(ceil(targetIndex./5),mod(targetIndex-1,5)+1,2,1) + sum(tmp_calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeXVolt);
                handles.gridData(targetIndex,2,2) = handles.gridData(ceil(targetIndex./5),mod(targetIndex-1,5)+1,2,2) + sum(tmp_calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeYVolt);
                %std
                stdXvector = cat(2,stdXvector,(tmp_calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeXVolt));
                stdYvector = cat(2,stdYvector,(tmp_calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeYVolt));
            end
        end
        % Then we get the mean by dividing by the number of samples (ie. number
        % of trials left times trial length
        handles.gridData(targetIndex,2,1) = handles.gridData(targetIndex,2,1)./(sum([tmp_calibData.targetData(targetIndex).eyeDataLeft.flag]).*length(tmp_calibData.targetData(targetIndex).eyeDataLeft(1).eyeXVolt));
        handles.gridData(targetIndex,2,2) = handles.gridData(targetIndex,2,2)./(sum([tmp_calibData.targetData(targetIndex).eyeDataLeft.flag]).*length(tmp_calibData.targetData(targetIndex).eyeDataLeft(1).eyeYVolt));
        % We also compute the standard deviation
        handles.gridData(targetIndex,3,1) = std(stdXvector); %std X
        handles.gridData(targetIndex,3,2) = std(stdYvector); %std Y
    end
end

handles.Xtargetcm = handles.gridData(:,1,1);
handles.Ytargetcm = handles.gridData(:,1,2);
handles.Xvolt = handles.gridData(:,2,1);
handles.Yvolt = handles.gridData(:,2,2);

% Choose default command line output for CalibStep2D
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = CalibStep2D_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in makeFit2D_button.
function makeFit2D_button_Callback(hObject, ~, handles)
% hObject    handle to makeFit2D_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Button press runs the fit function itself
fit2D(handles, hObject);


% Fit function
function handles = fit2D(handles, hObject)

eyeCalibObjID = findobj('Tag','EyeCalibWindow');
tmp_calibData = getappdata(eyeCalibObjID,'calibData');

xMinSetting = min(min(handles.Xvolt));
xMaxSetting = max(max(handles.Xvolt));
yMinSetting = min(min(handles.Yvolt));
yMaxSetting = max(max(handles.Yvolt));

% First step is to make a grid from the sparse data we get
XtargetVoltVect = [];
YtargetVoltVect = [];
XtargetcmVect = [];
YtargetcmVect = [];
% We define 2 vectors with the X and Y voltages we recorded
% and with the X and Y cm values of targets
for i = 1:1:size(handles.Xvolt,1)
    XtargetVoltVect = cat(2,XtargetVoltVect,handles.Xvolt(i,:));
    XtargetcmVect = cat(2,XtargetcmVect,handles.Xtargetcm(i,:));
end
for i = 1:1:size(handles.Yvolt,1)
    YtargetVoltVect = cat(2,YtargetVoltVect,handles.Yvolt(i,:));
    YtargetcmVect = cat(2,YtargetcmVect,handles.Ytargetcm(i,:));
end

rangeXcm = max(XtargetcmVect)-min(XtargetcmVect);
rangeYcm = max(YtargetcmVect)-min(YtargetcmVect);
% To test the benefit of the model and show the non-linearity importance,
% we also correct the data with a linear normalization for future comparison.
dummyX = ((((XtargetVoltVect - min(XtargetVoltVect)) ./ (max(XtargetVoltVect)-min(XtargetVoltVect)))) .* rangeXcm) + min(XtargetcmVect);
dummyY = ((((YtargetVoltVect - min(YtargetVoltVect)) ./ (max(YtargetVoltVect)-min(YtargetVoltVect)))) .* rangeYcm) + min(YtargetcmVect);

% Then we define a precise grid of voltage onto which the data will be
% adjusted.
preciseXVoltVect = xMinSetting:((xMaxSetting-xMinSetting)/handles.gridPrecision):xMaxSetting;
preciseYVoltVect = (yMinSetting:((yMaxSetting-yMinSetting)/handles.gridPrecision):yMaxSetting)';

% We create the fine grid that follows the skeleton of our data (note :
% it's a 3D grid because data are a function of X and Y voltages
preciseXcmMat = griddata(XtargetVoltVect,YtargetVoltVect,XtargetcmVect,preciseXVoltVect,preciseYVoltVect,handles.menuMethod);
preciseYcmMat = griddata(XtargetVoltVect,YtargetVoltVect,YtargetcmVect,preciseXVoltVect,preciseYVoltVect,handles.menuMethod);


% For now, we define the weight to apply to each point at 1
% Further optimization may add a possibility to affect that
myWeightMat = ones(size(preciseXVoltVect,2),size(preciseYVoltVect,1));

% We get the 2D polynomial functions that define the relationship between X
% and Y in cm and X or Y in volts.
% The polyfitweighted2 returns a parameter vector
%  P = [p00 p10 p01 p20 p11 p02 p30 p21 p12 p03...]
polynom_order = 4;
Px_tmp4 = polyfitweighted2(preciseXVoltVect,preciseYVoltVect,preciseXcmMat,polynom_order,myWeightMat);
Py_tmp4 = polyfitweighted2(preciseXVoltVect,preciseYVoltVect,preciseYcmMat,polynom_order,myWeightMat);

polynom_order = 3;
Px_tmp3 = polyfitweighted2(preciseXVoltVect,preciseYVoltVect,preciseXcmMat,polynom_order,myWeightMat);
Py_tmp3 = polyfitweighted2(preciseXVoltVect,preciseYVoltVect,preciseYcmMat,polynom_order,myWeightMat);

polynom_order = 2;
Px_tmp2 = polyfitweighted2(preciseXVoltVect,preciseYVoltVect,preciseXcmMat,polynom_order,myWeightMat);
Py_tmp2 = polyfitweighted2(preciseXVoltVect,preciseYVoltVect,preciseYcmMat,polynom_order,myWeightMat);


% We generate estimated eye positions for the 3 models
fitXcmGrid2 = polyval2(Px_tmp2,preciseXVoltVect,preciseYVoltVect);
fitYcmGrid2 = polyval2(Py_tmp2,preciseXVoltVect,preciseYVoltVect);
fitXcm2 = zeros(1,size(tmp_calibData.targetData,2));
fitYcm2 = zeros(1,size(tmp_calibData.targetData,2));
for i = 1:1:size(tmp_calibData.targetData,2)
    fitXcm2(i) = polyval2(Px_tmp2,XtargetVoltVect(i),YtargetVoltVect(i));
    fitYcm2(i) = polyval2(Py_tmp2,XtargetVoltVect(i),YtargetVoltVect(i));
end

fitXcmGrid3 = polyval2(Px_tmp3,preciseXVoltVect,preciseYVoltVect);
fitYcmGrid3 = polyval2(Py_tmp3,preciseXVoltVect,preciseYVoltVect);
fitXcm3 = zeros(1,size(tmp_calibData.targetData,2));
fitYcm3 = zeros(1,size(tmp_calibData.targetData,2));
for i = 1:1:size(tmp_calibData.targetData,2)
    fitXcm3(i) = polyval2(Px_tmp3,XtargetVoltVect(i),YtargetVoltVect(i));
    fitYcm3(i) = polyval2(Py_tmp3,XtargetVoltVect(i),YtargetVoltVect(i));
end

fitXcmGrid4 = polyval2(Px_tmp4,preciseXVoltVect,preciseYVoltVect);
fitYcmGrid4 = polyval2(Py_tmp4,preciseXVoltVect,preciseYVoltVect);
fitXcm4 = zeros(1,size(tmp_calibData.targetData,2));
fitYcm4 = zeros(1,size(tmp_calibData.targetData,2));
for i = 1:1:size(tmp_calibData.targetData,2)
    fitXcm4(i) = polyval2(Px_tmp4,XtargetVoltVect(i),YtargetVoltVect(i));
    fitYcm4(i) = polyval2(Py_tmp4,XtargetVoltVect(i),YtargetVoltVect(i));
end

% Polynom coefficients vector is 15 elements long, so we fill PX with zeros
% that will stay for high order coefficients if order is lower than 4.
Px = zeros(1,15);
Py = zeros(1,15);

switch handles.model_order
    case 2
        Px(end - (size(Px_tmp2,2)-1):end) = Px_tmp2;
        Py(end - (size(Py_tmp2,2)-1):end) = Py_tmp2;
        axes(handles.calibAxesX);
        cla
        mesh(preciseXVoltVect,preciseYVoltVect,fitXcmGrid2);
        xlabel('X volt');
        ylabel('Y volt');
        zlabel('X cm');
        set(gca,'XColor',[11/255 132/255 199/255],'YColor',[11/255 132/255 199/255],'ZColor',[11/255 132/255 199/255]);
        
        axes(handles.calibAxesY);
        cla
        mesh(preciseXVoltVect,preciseYVoltVect,fitYcmGrid2);
        xlabel('X volt');
        ylabel('Y volt');
        zlabel('Y cm');
        set(gca,'XColor',[11/255 132/255 199/255],'YColor',[11/255 132/255 199/255],'ZColor',[11/255 132/255 199/255]);
        
    case 3
        Px(end - (size(Px_tmp3,2)-1):end) = Px_tmp3;             % ADD THE model order in the handle under the control of the radio buttons
        Py(end - (size(Py_tmp3,2)-1):end) = Py_tmp3;
        axes(handles.calibAxesX);
        cla
        mesh(preciseXVoltVect,preciseYVoltVect,fitXcmGrid3);
        xlabel('X volt');
        ylabel('Y volt');
        zlabel('X cm');
        set(gca,'XColor',[11/255 132/255 199/255],'YColor',[11/255 132/255 199/255],'ZColor',[11/255 132/255 199/255]);
        
        axes(handles.calibAxesY);
        cla
        mesh(preciseXVoltVect,preciseYVoltVect,fitYcmGrid3);
        xlabel('X volt');
        ylabel('Y volt');
        zlabel('Y cm');
        set(gca,'XColor',[11/255 132/255 199/255],'YColor',[11/255 132/255 199/255],'ZColor',[11/255 132/255 199/255]);
        
    case 4
        Px(end - (size(Px_tmp4,2)-1):end) = Px_tmp4;
        Py(end - (size(Py_tmp4,2)-1):end) = Py_tmp4;
        axes(handles.calibAxesX);
        cla
        mesh(preciseXVoltVect,preciseYVoltVect,fitXcmGrid4);
        xlabel('X volt');
        ylabel('Y volt');
        zlabel('X cm');
        set(gca,'XColor',[11/255 132/255 199/255],'YColor',[11/255 132/255 199/255],'ZColor',[11/255 132/255 199/255]);
        
        axes(handles.calibAxesY);
        cla
        mesh(preciseXVoltVect,preciseYVoltVect,fitYcmGrid4);
        xlabel('X volt');
        ylabel('Y volt');
        zlabel('Y cm');
        set(gca,'XColor',[11/255 132/255 199/255],'YColor',[11/255 132/255 199/255],'ZColor',[11/255 132/255 199/255]);
end

% We put the coefficients into the handle
handles.paramX = Px;
handles.paramY = Py;

%*************************************************************************

% Update handles structure
guidata(hObject, handles);

axes(handles.calib_model_2);
cla
plot(XtargetcmVect,YtargetcmVect,'ko')
hold on
plot(fitXcm2,fitYcm2,'g*')
plot(dummyX,dummyY,'r*')
axis([min([min(XtargetcmVect) min(fitXcm2) min(dummyX)])*0.8 ...
    max([max(XtargetcmVect) max(fitXcm2) max(dummyX)])*1.2 ...
    min([min(YtargetcmVect) min(fitYcm2) min(dummyY)])*0.8 ...
    max([max(YtargetcmVect) max(fitYcm2) max(dummyY)])*1.2]);
xlabel('X cm');
ylabel('Y cm');
set(gca,'XColor',[11/255 132/255 199/255],'YColor',[11/255 132/255 199/255]);


axes(handles.calib_model_3);
cla
plot(XtargetcmVect,YtargetcmVect,'ko')
hold on
plot(fitXcm3,fitYcm3,'g*')
plot(dummyX,dummyY,'r*')
axis([min([min(XtargetcmVect) min(fitXcm3) min(dummyX)])*0.9 ...
    max([max(XtargetcmVect) max(fitXcm3) max(dummyX)])*1.1 ...
    min([min(YtargetcmVect) min(fitYcm3) min(dummyY)])*0.9 ...
    max([max(YtargetcmVect) max(fitYcm3) max(dummyY)])*1.1]);
xlabel('X cm');
ylabel('Y cm');
set(gca,'XColor',[11/255 132/255 199/255],'YColor',[11/255 132/255 199/255]);

axes(handles.calib_model_4);
cla
plot(XtargetcmVect,YtargetcmVect,'ko')
hold on
plot(fitXcm4,fitYcm4,'g*')
plot(dummyX,dummyY,'r*')
axis([min([min(XtargetcmVect) min(fitXcm4) min(dummyX)])*0.9 ...
    max([max(XtargetcmVect) max(fitXcm4) max(dummyX)])*1.1 ...
    min([min(YtargetcmVect) min(fitYcm4) min(dummyY)])*0.9 ...
    max([max(YtargetcmVect) max(fitYcm4) max(dummyY)])*1.1]);
xlabel('X cm');
ylabel('Y cm');
set(gca,'XColor',[11/255 132/255 199/255],'YColor',[11/255 132/255 199/255]);


% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, ~, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Put the coefficient into the handle when save button is clicked
%try
for i = 1:1:15
    savedfitXfunction.coef{i} = handles.paramX(i);
    savedfitYfunction.coef{i} = handles.paramY(i);
end

gridData_to_save = handles.gridData;
FileName = 'gridData.mat';

eyeCalibObjID = findobj('Tag','EyeCalibWindow');
if ~isempty(eyeCalibObjID)
    handles.pref = getappdata(eyeCalibObjID,'pref');
    PathName = handles.pref.default_metadata_path;
else
    disp('Error in the path: No EyeCalibWindow object found')
    return
end

%[FileName,PathName] = uiputfile('.mat','gridata saving','gridData');
save('-mat',[PathName '\' FileName],'gridData_to_save');
handles.saveStatus = 1;
guidata(hObject, handles);
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
setappdata(eyeCalibObjID,'savedfitXfunction',savedfitXfunction.coef);
setappdata(eyeCalibObjID,'savedfitYfunction',savedfitYfunction.coef);

% --- Executes on button press in quitButton.
function quitButton_Callback(~, ~, handles)
% hObject    handle to quitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Quit the figure
%If the saved data are different from the actual data, display a messageBox
%if the user want to quit without saving the data
% One click on quit, we check if changes have been saved.
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
savedfitXfunction.coef = getappdata(eyeCalibObjID,'savedfitXfunction');
if handles.saveStatus == 1
    if  isequal(savedfitXfunction.coef{1},handles.paramX(1)) && isequal(savedfitXfunction.coef{2},handles.paramX(2)) && isequal(savedfitXfunction.coef{3},handles.paramX(3))
        close(figure(1));
        close;
    else
        selection = questdlg('Close without saving the modifications ?',...
            'Close ' ,...
            'Yes','No','Yes');
        if strcmp(selection,'No')
            return;
        elseif strcmp(selection,'Yes')
            close (figure(1));
            close (figure(2));
            close;
        end
        
    end
else
    selection = questdlg('Close without saving the modifications ?',...
        'Close ' ,...
        'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    elseif strcmp(selection,'Yes')
        close (figure(1));
        close (figure(2));
        close;
    end
    
end

% --- Executes on selection change in interp_method.
function interp_method_Callback(hObject, ~, handles)
% hObject    handle to interp_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
handles.menuMethod = contents{get(hObject,'Value')};
%       'nearest'   - Nearest neighbor interpolation
%       'linear'    - Linear interpolation (default)
%       'natural'   - Natural neighbor interpolation
%       'cubic'     - Cubic interpolation (2D only)
%       'v4' 
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function interp_method_CreateFcn(hObject, ~, handles)
% hObject    handle to interp_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.menuMethod = 'v4';
guidata(hObject, handles);


% --- Executes on selection change in precisionMenu.
function precisionMenu_Callback(hObject, ~, handles)
% hObject    handle to precisionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns precisionMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from precisionMenu

contents = cellstr(get(hObject,'String'));
menuPrecision = contents{get(hObject,'Value')};
if strcmp(menuPrecision,'1/2')
    handles.gridPrecision = 2;
elseif strcmp(menuPrecision,'1/4')
    handles.gridPrecision = 4;
elseif strcmp(menuPrecision,'1/8')
    handles.gridPrecision = 8;
elseif strcmp(menuPrecision,'1/16')
    handles.gridPrecision = 16;
else
    handles.gridPrecision = 10;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function precisionMenu_CreateFcn(hObject, ~, handles)
% hObject    handle to precisionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.gridPrecision = 10;
guidata(hObject, handles);


% --- Executes on button press in select_order_2.
function select_order_2_Callback(hObject, ~, handles)
% hObject    handle to select_order_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_order_2
handles.select_2_status = get(hObject,'Value');
handles.select_3_status = get(handles.select_order_3,'Value');
handles.select_4_status = get(handles.select_order_4,'Value');
guidata(hObject, handles);

% --- Executes on button press in select_order_3.
function select_order_3_Callback(hObject, ~, handles)
% hObject    handle to select_order_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_order_3
handles.select_2_status = get(handles.select_order_2,'Value');
handles.select_3_status = get(hObject,'Value');
handles.select_4_status = get(handles.select_order_4,'Value');
guidata(hObject, handles);

% --- Executes on button press in select_order_4.
function select_order_4_Callback(hObject, ~, handles)
% hObject    handle to select_order_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_order_4
handles.select_2_status = get(handles.select_order_2,'Value');
handles.select_3_status = get(handles.select_order_3,'Value');
handles.select_4_status = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes when selected object is changed in order_choice.
function order_choice_SelectionChangedFcn(hObject, ~, handles)
% hObject    handle to the selected object in order_choice
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.select_2_status = get(handles.select_order_2,'Value');
handles.select_3_status = get(handles.select_order_3,'Value');
handles.select_4_status = get(handles.select_order_4,'Value');
if handles.select_2_status == 1
    handles.model_order = 2;
elseif handles.select_3_status == 1
    handles.model_order = 3;
elseif handles.select_4_status == 1
    handles.model_order = 4;
end
guidata(hObject, handles);
fit2D(handles, hObject);
