function varargout = setpref(varargin)
% SETPREF MATLAB code for setpref.fig
%      SETPREF, by itself, creates a new SETPREF or raises the existing
%      singleton*.
%
%      H = SETPREF returns the handle to a new SETPREF or the handle to
%      the existing singleton*.
%
%      SETPREF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETPREF.M with the given input arguments.
%
%      SETPREF('Property','Value',...) creates a new SETPREF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setpref_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setpref_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setpref

% Last Modified by GUIDE v2.5 26-Mar-2018 13:53:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setpref_OpeningFcn, ...
                   'gui_OutputFcn',  @setpref_OutputFcn, ...
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


% --- Executes just before setpref is made visible.
function setpref_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setpref (see VARARGIN)
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
if ~isempty(eyeCalibObjID)
    handles.pref = getappdata(eyeCalibObjID,'pref');
    handles.eye_calib_folder = getappdata(eyeCalibObjID,'eye_calib_folder');
end

% Choose default command line output for setpref
set(handles.choosen_task_dir,'UserData',handles.pref.default_dext_task_path);
set(handles.choosen_data_dir,'UserData',handles.pref.default_dext_data_path);
set(handles.choosen_metadata_dir,'UserData',handles.pref.default_metadata_path);
set(handles.choosen_task_dir,'String',handles.pref.default_dext_task_path);
set(handles.choosen_data_dir,'String',handles.pref.default_dext_data_path);
set(handles.choosen_metadata_dir,'String',handles.pref.default_metadata_path);
set(handles.always_mat_checkbox,'Value',handles.pref.always_mat_chk);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setpref wait for user response (see UIRESUME)
% uiwait(handles.setprefWindow);


% --- Outputs from this function are returned to the command line.
function varargout = setpref_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure


% --- Executes on button press in change_task_dir_button.
function change_task_dir_button_Callback(hObject, ~, handles)
% hObject    handle to change_task_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.pref.default_dext_task_path == 0
    handles.pref.default_dext_task_path = '';
end
handles.pref.default_dext_task_path = uigetdir(handles.pref.default_dext_task_path, 'Select new default task directory');
set(handles.choosen_task_dir,'UserData',handles.pref.default_dext_task_path);
set(handles.choosen_task_dir,'String',handles.pref.default_dext_task_path);
default_dext_task_path = handles.pref.default_dext_task_path;
save([handles.eye_calib_folder '\Preferences.mat'],'default_dext_task_path','-append');

guidata(hObject, handles);

% --- Executes on button press in change_data_dir_button.
function change_data_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to change_data_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.pref.default_dext_data_path == 0
    handles.pref.default_dext_data_path = '';
end
handles.pref.default_dext_data_path = uigetdir(handles.pref.default_dext_data_path, 'Select new default task directory');
set(handles.choosen_data_dir,'UserData',handles.pref.default_dext_data_path);
set(handles.choosen_data_dir,'String',handles.pref.default_dext_data_path);
default_dext_data_path = handles.pref.default_dext_data_path;
save([handles.eye_calib_folder '\Preferences.mat'],'default_dext_data_path','-append');
guidata(hObject, handles);

% --- Executes on button press in change_metadata_dir_button.
function change_metadata_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to change_metadata_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.pref.default_metadata_path == 0
    handles.pref.default_metadata_path = '';
end
handles.pref.default_metadata_path = uigetdir(handles.pref.default_metadata_path, 'Select new default task directory');
set(handles.choosen_metadata_dir,'UserData',handles.pref.default_metadata_path);
set(handles.choosen_metadata_dir,'String',handles.pref.default_metadata_path);
default_metadata_path = handles.pref.default_metadata_path;
save([handles.eye_calib_folder '\Preferences.mat'],'default_metadata_path','-append');
guidata(hObject, handles);


% --- Executes on button press in pref_quit_button.
function pref_quit_button_Callback(hObject, eventdata, handles)
% hObject    handle to pref_quit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargout{1} = handles.pref;
% 
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
setappdata(eyeCalibObjID,'pref',handles.pref);
close;


% --- Executes on button press in always_mat_checkbox.
function always_mat_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to always_mat_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of always_mat_checkbox
always_mat_chk = get(hObject,'Value');
handles.pref.always_mat_chk = always_mat_chk;
save([handles.eye_calib_folder '\Preferences.mat'],'always_mat_chk','-append');
guidata(hObject, handles);


