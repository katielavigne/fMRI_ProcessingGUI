function varargout = datasetupfMRI(varargin)
% DATASETUPFMRI MATLAB code for datasetupfMRI.fig
%      DATASETUPFMRI, by itself, creates a new DATASETUPFMRI or raises the existing
%      singleton*.
%
%      H = DATASETUPFMRI returns the handle to a new DATASETUPFMRI or the handle to
%      the existing singleton*.
%
%      DATASETUPFMRI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASETUPFMRI.M with the given input arguments.
%
%      DATASETUPFMRI('Property','Value',...) creates a new DATASETUPFMRI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before datasetupfMRI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to datasetupfMRI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%% DOCUMENTATION
%
% AUTHOR: Katie Lavigne (lavigne.k@gmail.com)
% DATE: January 25th, 2016
% 
% FILE:     datasetupfMRI.m (paired with datasetupfMRI.fig)
% PURPOSE:  This is the GUIDE-created file for the Data Setup portion of the EEG GUI.
% USAGE:    Click Data Setup: Functional in the EEG GUI.
% 
% DESCRIPTION: This file, in addition to datasetupfMRI.fig, is the file created by MATLAB's
% Graphic User Interface Design Environment (GUIDE) for the Data Setup portion of the GUI.
% It defines what is done when each button/checkbox/etc is pressed/changed in the GUI.

% Edit the above text to modify the response to help datasetupfMRI

% Last Modified by GUIDE v2.5 09-Nov-2016 11:30:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @datasetupfMRI_OpeningFcn, ...
                   'gui_OutputFcn',  @datasetupfMRI_OutputFcn, ...
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


% --- Executes just before datasetupfMRI is made visible.
function datasetupfMRI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to datasetupfMRI (see VARARGIN)
spm_path = fileparts(which('spm'));
handles.spmdir = spm_path;
    
if ~isempty(getappdata(0,'datasetup_vals'))
    tmp = getappdata(0,'datasetup_vals');
    set(handles.funcdirtext, 'String', tmp.funcdir);
    set(handles.swild, 'String', tmp.subject);
    set(handles.rwild, 'String', tmp.run);
    set(handles.scwild, 'String', tmp.scan);
    handles.funcdir = tmp.funcdir;
    handles.subject = tmp.subject;
    handles.run = tmp.run;
    handles.scan = tmp.scan;
    handles.subjs = structtmp.subjs;
    handles.structdir = tmp.structdir;
    handles.t1prefix = tmp.t1prefix;
    handles.t1type = tmp.t1type;
    handles.t1prefix2 = tmp.t1prefix2;
    handles.t1suffix = tmp.t1suffix;
    handles.t1ext = tmp.t1ext;
    handles.T1subjs = tmp.T1subjs;
    guidata(hObject, handles);
else
    handles.funcdir = 'No Directory Selected!';
    handles.subject = '';
    handles.run = '';
    handles.scan = '';
    handles.subjs = '';
    handles.structdir = 'No Directory Selected!';
    handles.t1prefix = '';
    handles.t1type = '';
    handles.t1prefix2 = '';
    handles.t1suffix = '';
    handles.t1ext = '';
    handles.T1subjs = '';
end

% Choose default command line output for datasetupfMRI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes datasetupfMRI wait for user response (see UIRESUME)
% uiwait(handles.datasetupfMRI);

% --- Outputs from this function are returned to the command line.
function varargout = datasetupfMRI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in funcdir.
function funcdir_Callback(hObject, eventdata, handles)
% hObject    handle to funcdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.funcdir = uigetdir(pwd,'Select Subject Scan Directory');
if handles.funcdir == 0
    handles.funcdir = 'No Directory Selected!';
end
set(handles.funcdirtext, 'String', handles.funcdir)
guidata(hObject, handles);


function swild_Callback(hObject, eventdata, handles)
% hObject    handle to swild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of swild as text
%        str2double(get(hObject,'String')) returns contents of swild as a double
handles.subject = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function swild_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rwild_Callback(hObject, eventdata, handles)
% hObject    handle to rwild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rwild as text
%        str2double(get(hObject,'String')) returns contents of rwild as a double
handles.run = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function rwild_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rwild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function scwild_Callback(hObject, eventdata, handles)
% hObject    handle to scwild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scwild as text
%        str2double(get(hObject,'String')) returns contents of scwild as a double
handles.scan = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function scwild_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scwild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subjs = dir([handles.funcdir,'/',handles.subject]);
subjs=subjs(~strncmpi('.',{subjs.name},1)); % Remove hidden folders (folders starting with '.')
sflag = [subjs.isdir]; % directories only
subjs = subjs(sflag); % directories only
datasetup_vals = struct('funcdir', handles.funcdir, ...
    'spmdir', handles.spmdir, ...
    'subject', handles.subject, ...
    'run', handles.run, ...
    'scan', handles.scan, ...
    'subjs', subjs, ...
    'structdir', handles.structdir, ...
    't1prefix', handles.t1prefix, ...
    't1type', handles.t1type, ...
    't1prefix2', handles.t1prefix2, ...
    't1suffix', handles.t1suffix, ...
    't1ext', handles.t1ext, ...
    'T1subjs', handles.T1subjs);
setappdata(0, 'datasetup_vals', datasetup_vals);
close(handles.datasetup);


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.datasetup);


% --- Executes when user attempts to close datasetupfMRI.
function datasetup_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to datasetupfMRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
