function varargout = CalibStep1(varargin)
% FIGURE1 MATLAB code for figure1.fig
%      FIGURE1, by itself, creates a new FIGURE1 or raises the existing
%      singleton*.
%
%      H = FIGURE1 returns the handle to a new FIGURE1 or the handle to
%      the existing singleton*.
%F
%      FIGURE1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE1.M with the given input arguments.
%
%      FIGURE1('Property','Value',...) creates a new FIGURE1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CalibStep1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CalibStep1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%       CalibStep1 displays recorded samples for each target in separated
%       plots. On the right is a global XY plot of eyelink mean output
%       where you can follow the data grid evolution when you flag a trial.
%
%       Above, in the frame, the checkbox allows you to switch between
%       fixed scale (-5/+5v for all plots) or adjusted scale.
%
%       After you made some changes you must click the [APPLY] button to
%       save the modifications.
%       If you press the [QUIT] button, the CalibStep1 is closed and
%       unapplied changes are lost.
%
%
% Last Modified by FVB 23-Dec-2014 15:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CalibStep1_OpeningFcn, ...
    'gui_OutputFcn',  @CalibStep1_OutputFcn, ...
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


% --- Executes just before figure1 is made visible.
function CalibStep1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figure1 (see VARARGIN)

% Choose default command line output for figure1
handles.output = hObject;

eyeCalibObjID = findobj('Tag','EyeCalibWindow');
calibData = getappdata(eyeCalibObjID,'calibData');


handles.currentAxe = varargin{1};

% Test if Step should be applied
for targetIndex=1:1:size(calibData.targetData,2)
    eval(['set(handles.axes' num2str(targetIndex) ',''NextPlot'',''replacechildren'');']);  % <-- TO keep possibility to click on axes event after plot in it
    eval(['axes(handles.axes' num2str(targetIndex) ')']); % Select axes1 to write to
    for trialIndex = 1:calibData.targetData(targetIndex).nbTrial
        if(  targetIndex > 20 )
            xlabel('Time (ms)','Color', get(gca, 'XColor'));
        end
        if(mod(targetIndex, 5) == 1 )
            ylabel('Eye Position (V)', 'Color', get(gca, 'YColor'));
        end
        
        if strcmp(calibData.setupData.eyeSelection,'Right')
            
            
            if calibData.targetData(targetIndex).eyeDataRight(trialIndex).flagTemp == 1
                if strcmp(handles.currentAxe,'X')
                    plot(1:length(calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeXVolt),calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeXVolt,'w-');
                else
                    plot(1:length(calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeYVolt),calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeYVolt,'w-');
                end
                hold on
            elseif calibData.targetData(targetIndex).eyeDataRight(trialIndex).flagTemp == 0
                if strcmp(handles.currentAxe,'X')
                    plot(1:length(calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeXVolt),calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeXVolt,'r-');
                else
                    plot(1:length(calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeYVolt),calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeYVolt,'r-');
                end
                hold on
            end
            
        else
            if calibData.targetData(targetIndex).eyeDataLeft(trialIndex).flagTemp == 1
                if strcmp(handles.currentAxe,'X')
                    plot(1:length(calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeXVolt),calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeXVolt,'w-');
                else
                    plot(1:length(calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeYVolt),calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeYVolt,'w-');
                end
                hold on
            elseif calibData.targetData(targetIndex).eyeDataLeft(trialIndex).flagTemp == 0
                if strcmp(handles.currentAxe,'X')
                    plot(1:length(calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeXVolt),calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeXVolt,'r-');
                else
                    plot(1:length(calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeYVolt),calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeYVolt,'r-');
                end
                hold on
            end
            
        end
        
    end
end

%virtualTagetDisplay

axes(handles.VirtualTableaxes);
xlabel('X-Voltage (V)', 'Color', get(gca, 'XColor'));
ylabel('Y-Voltage (V)', 'Color', get(gca, 'YColor'));

spacePlot(handles);
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = CalibStep1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in applyStep1.
function applyStep1_Callback(hObject, eventdata, handles)
%each trial's temp flag is copied into the orginal flag. this one is used in
%CalibStep1 and ZoomTarget figure. It allows to know if the user has made
%any modifications during the previous figure. (usefull in ApplyChange
%Button and QuitButton in CalibStep1 and ZoomTarget)
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
tmp_calibData = getappdata(eyeCalibObjID,'calibData');

if strcmp(tmp_calibData.setupData.eyeSelection,'Right')
    
    for targetNum = 1:size(tmp_calibData.targetData,2)
        for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
            tmp_calibData.targetData(targetNum).eyeDataRight(trialIndex).flag = tmp_calibData.targetData(targetNum).eyeDataRight(trialIndex).flagTemp;
%each trial's temp flag is copied into the orginal flag. this one is used in
%CalibStep1 and ZoomTarget figure. It allows to know if the user has made
%any modifications during the previous figure. (usefull in ApplyChange
%Button and QuitButton in CalibStep1 and ZoomTarget)
        end
    end
    
else
    for targetNum = 1:size(tmp_calibData.targetData,2)
        for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
            tmp_calibData.targetData(targetNum).eyeDataLeft(trialIndex).flag = tmp_calibData.targetData(targetNum).eyeDataLeft(trialIndex).flagTemp;
%each trial's temp flag is copied into the orginal flag. this one is used in
%CalibStep1 and ZoomTarget figure. It allows to know if the user has made
%any modifications during the previous figure. (usefull in ApplyChange
%Button and QuitButton in CalibStep1 and ZoomTarget)
        end
    end
end
setappdata(eyeCalibObjID,'calibData',tmp_calibData);
disp('APPLY CHANGES');

% --- Executes on button press in quitStep1.
function quitStep1_Callback(hObject, eventdata, handles)
% Exit the figure after checking if the data are changed or not. If it's
% the case and the user didn't save them before, it will display a
% messageBox asking if the user want to save modified data.
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
tmp_calibData = getappdata(eyeCalibObjID,'calibData');

%boolean which compare if the data are changed or not
changesDone = 0;

if strcmp(tmp_calibData.setupData.eyeSelection,'Right')
    
    for targetNum = 1:size(tmp_calibData.targetData,2)
        for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
            %if the temp flag and flag are different, the boolean -> 1, and
            %exit the for loop
            if tmp_calibData.targetData(targetNum).eyeDataRight(trialIndex).flag ~= tmp_calibData.targetData(targetNum).eyeDataRight(trialIndex).flagTemp
                changesDone = 1;
                break
            end
        end
    end
    
else
    for targetNum = 1:size(tmp_calibData.targetData,2)
        for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
            %if the temp flag and flag are different, the boolean -> 1, and
            %exit the for loop
            if tmp_calibData.targetData(targetNum).eyeDataLeft(trialIndex).flag ~= tmp_calibData.targetData(targetNum).eyeDataLeft(trialIndex).flagTemp
                changesDone = 1;
                break
            end
        end
    end
end
%if there was any modifications, the messageBox appears and ask the user
%if he really wants to quit the figure
if changesDone == 1
    selection = questdlg('Close without aplying changes ?',...
        'Close ' ,...
        'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end
end

%Remove the field tempFlag
if strcmp(tmp_calibData.setupData.eyeSelection,'Right')    
    for targetNum = 1:size(tmp_calibData.targetData,2)
        for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
            bufferStruct(trialIndex) = tmp_calibData.targetData(targetNum).eyeDataRight(trialIndex);
        end
        bufferStruct = rmfield(bufferStruct,'flagTemp');
        tmp_calibData.targetData(targetNum).eyeDataRight = bufferStruct;
        clear bufferStruct
    end
    
else
    for targetNum = 1:size(tmp_calibData.targetData,2)
        for trialIndex = 1:tmp_calibData.targetData(targetNum).nbTrial
            bufferStruct(trialIndex) = tmp_calibData.targetData(targetNum).eyeDataLeft(trialIndex);
        end
        bufferStruct = rmfield(bufferStruct,'flagTemp');
        tmp_calibData.targetData(targetNum).eyeDataLeft = bufferStruct;
        clear bufferStruct
    end
    
end
setappdata(eyeCalibObjID,'calibData',tmp_calibData);
close;

%**************************************************************************
%                      START OF THE ZOOM FUNCTIONS
%**************************************************************************
% The next 25 functions call ZoomTarget with the target number as argument.

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(1,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(2,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(3,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(4,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(5,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(6,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes7_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(7,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes8_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(8,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes9_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(9,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes10_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(10,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes11_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(11,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes12_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(12,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes13_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(13,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes14_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(14,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes15_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(15,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes16_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(16,handles.currentAxe);
% --- Executes on mouse press over axes background.
function axes17_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ZoomTarget(17,handles.currentAxe);
%**************************************************************************
%                      END OF THE ZOOM FUNCTIONS
%**************************************************************************

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in scalecheckbox.
function scalecheckbox_Callback(hObject, eventdata, handles)
% Change the scale axis on Y between automatic scaling from matlab and -/+ 5


eyeCalibObjID = findobj('Tag','EyeCalibWindow');
tmp_calibData = getappdata(eyeCalibObjID,'calibData');
%if the checkBox is checked we change to -/+ 5 if not, we readjust with the
%autmatic scaling from Matlab
if get(hObject,'Value') == 1
    for targetIndex = 1:1:size(tmp_calibData.targetData,2)
        eval(['axes(handles.axes' num2str(targetIndex) ')']); % Select axes1 to write to
        set(gca ,'YLim', [-5 5]);
    end
else
    for targetIndex = 1:1:size(tmp_calibData.targetData,2)
        
        eval(['axes(handles.axes' num2str(targetIndex) ')']); % Select axes1 to write to
        set(gca ,'YLimMode', 'auto');
        
    end
end


% --- Executes on button press in printButton.
function printButton_Callback(hObject, eventdata, handles)
% hObject    handle to printButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    struprint(gcf, '-depsc', 'toto.eps');
set(gcf,'PaperPositionMode','auto')
%print(gcf, '-depsc', 'toto.eps');
saveas(gcf, 'toto', 'pdf');
saveas(gcf, 'toto', 'eps');
%print(gcf, '-dpdf', 'toto.pdf','-zbuffer','-r200');
%print(gcf, '-depsc2' , 'toto2.eps');

function spacePlot(handles)
% Plots the non corrected grid using unflagged data only

eyeCalibObjID = findobj('Tag','EyeCalibWindow');
tmp_calibData = getappdata(eyeCalibObjID,'calibData');
%select the correct axis
axes(handles.VirtualTableaxes);
set(gca ,'XLim', [-5 5]) ;
set(gca ,'YLim', [-5 5]) ;
graphData = zeros(4,25);

%Get the trials mean for each target and put it in graphData.
if strcmp(tmp_calibData.setupData.eyeSelection,'Right')
    
    for targetIndex = 1:1:size(tmp_calibData.targetData,2)
        
        for trialIndex = 1:1:tmp_calibData.targetData(targetIndex).nbTrial
            
            graphData(1,targetIndex) = tmp_calibData.targetData(targetIndex).targetXpos;
            graphData(2,targetIndex) = tmp_calibData.targetData(targetIndex).targetYpos;
            
            
            if tmp_calibData.targetData(targetIndex).eyeDataRight(trialIndex).flag == 1 && tmp_calibData.targetData(targetIndex).eyeDataRight(trialIndex).flagTemp == 1
                graphData(3,targetIndex) = graphData(3,targetIndex) + sum(tmp_calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeXVolt);
                graphData(4,targetIndex) = graphData(4,targetIndex) + sum(tmp_calibData.targetData(targetIndex).eyeDataRight(trialIndex).eyeYVolt);
                
            end
        end
        graphData(3,targetIndex) = graphData(3,targetIndex)./(sum([tmp_calibData.targetData(targetIndex).eyeDataRight.flagTemp]).*length(tmp_calibData.targetData(targetIndex).eyeDataRight(1).eyeXVolt));
        graphData(4,targetIndex) = graphData(4,targetIndex)./(sum([tmp_calibData.targetData(targetIndex).eyeDataRight.flagTemp]).*length(tmp_calibData.targetData(targetIndex).eyeDataRight(1).eyeXVolt));
    end
else
    for targetIndex = 1:1:size(tmp_calibData.targetData,2)
        
        
        for trialIndex = 1:1:tmp_calibData.targetData(targetIndex).nbTrial
            
            graphData(1,targetIndex) = tmp_calibData.targetData(targetIndex).targetXpos;
            graphData(2,targetIndex) = tmp_calibData.targetData(targetIndex).targetYpos;
            
            
            if tmp_calibData.targetData(targetIndex).eyeDataLeft(trialIndex).flag == 1 && tmp_calibData.targetData(targetIndex).eyeDataLeft(trialIndex).flagTemp == 1
                graphData(3,targetIndex) = graphData(3,targetIndex) + sum(tmp_calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeXVolt);
                graphData(4,targetIndex) = graphData(4,targetIndex) + sum(tmp_calibData.targetData(targetIndex).eyeDataLeft(trialIndex).eyeYVolt);
                
            end
        end
        graphData(3,targetIndex) = graphData(3,targetIndex)./(sum([tmp_calibData.targetData(targetIndex).eyeDataLeft.flagTemp]).*length(tmp_calibData.targetData(targetIndex).eyeDataLeft(1).eyeXVolt));
        graphData(4,targetIndex) = graphData(4,targetIndex)./(sum([tmp_calibData.targetData(targetIndex).eyeDataLeft.flagTemp]).*length(tmp_calibData.targetData(targetIndex).eyeDataLeft(1).eyeXVolt));
    end
    
end
for i = 1:1:size(tmp_calibData.targetData,2)
    
        spaceMatrix(i,1) = graphData(3,i);
        spaceMatrix(i,2) = graphData(4,i);
    
end

%plot the o and - on the graph.
for plotIndex = 1:1:size(tmp_calibData.targetData,2)
    
    plot(spaceMatrix(plotIndex,1),spaceMatrix(plotIndex,2),'ro-');
    hold on
    
end
