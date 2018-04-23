function varargout = select_dtp(varargin)
% SELECT_DTP MATLAB code for select_dtp.fig
%      SELECT_DTP, by itself, creates a new SELECT_DTP or raises the existing
%      singleton*.
%
%      H = SELECT_DTP returns the handle to a new SELECT_DTP or the handle to
%      the existing singleton*.
%
%      SELECT_DTP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_DTP.M with the given input arguments.
%
%      SELECT_DTP('Property','Value',...) creates a new SELECT_DTP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_dtp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_dtp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_dtp

% Last Modified by GUIDE v2.5 23-Mar-2018 16:43:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_dtp_OpeningFcn, ...
                   'gui_OutputFcn',  @select_dtp_OutputFcn, ...
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


% --- Executes just before select_dtp is made visible.
function select_dtp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to select_dtp (see VARARGIN)

% Choose default command line output for select_dtp
handles.output = hObject;
eyeCalibObjID = findobj('Tag','EyeCalibWindow');
handles.pref = getappdata(eyeCalibObjID,'pref');

origin_directory = pwd;                                               %  <----- THIS ONE SHOULD BE REPLACED BY THE DEFAULT TASK DIRECTORY
% Get the list of dtp files in the dexterit-e task subdirectories
handles.fileList = getAllFiles(origin_directory, '*.dtp', 1);
handles.fileList_short = getAllFiles(origin_directory, '*.dtp', 0);

% Set the listbox with the full list
set(handles.source_file_list,'string',handles.fileList);
handles.hide_status = 0;
handles.param = varargin{1};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes select_dtp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function fileList = getAllFiles(dirName, fileExtension, appendFullPath)
  dirData = dir([dirName '/' fileExtension]);      %# Get the data for the current directory
  dirWithSubFolders = dir(dirName);
  dirIndex = [dirWithSubFolders.isdir];  %# Find the index for directories
  fileList = {dirData.name}';  %'# Get a list of the files
  if ~isempty(fileList)
    if appendFullPath
      fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
    end
  end
  subDirs = {dirWithSubFolders(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir, fileExtension, appendFullPath)];  %# Recursively call getAllFiles
  end



% --- Outputs from this function are returned to the command line.
function varargout = select_dtp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in source_file_list.
function source_file_list_Callback(hObject, ~, handles)
% hObject    handle to source_file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns source_file_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from source_file_list
% Choose default command line output for select_dtp
handles.output = hObject;
contents = cellstr(get(hObject,'String'));
handles.current_source_selection = contents(get(hObject,'Value'));
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in hide_path_checkbox.
function hide_path_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to hide_path_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide_path_checkbox
handles.hide_status = get(hObject,'Value');
hide_status = handles.hide_status;
switch hide_status
    case 1
        set(handles.source_file_list,'string',handles.fileList_short)
    case 0
        set(handles.source_file_list,'string',handles.fileList);
end
guidata(hObject, handles);
%source_file_list_Callback(hObject, eventdata, handles);


% --- Executes on button press in apply_changes.
function apply_changes_Callback(hObject, eventdata, handles)
% hObject    handle to apply_changes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = handles.current_source_selection;
param = handles.param;
for i = 1:1:size(selection,1)
    save2dtp(param,selection{i});
end

% --- Executes during object creation, after setting all properties.
function source_file_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
