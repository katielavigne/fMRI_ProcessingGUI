function varargout = datasetupT1(varargin)
% DATASETUPT1 MATLAB code for datasetupT1.fig
%      DATASETUPT1, by itself, creates a new DATASETUPT1 or raises the existing
%      singleton*.
%
%      H = DATASETUPT1 returns the handle to a new DATASETUPT1 or the handle to
%      the existing singleton*.
%
%      DATASETUPT1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASETUPT1.M with the given input arguments.
%
%      DATASETUPT1('Property','Value',...) creates a new DATASETUPT1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before datasetupT1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to datasetupT1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%% DOCUMENTATION
%
% AUTHOR: Katie Lavigne (lavigne.k@gmail.com)
% DATE: November 8th, 2016
% 
% FILE:     datasetupT1.m (paired with datasetupT1.fig)
% PURPOSE:  This is the GUIDE-created file for the Data Setup portion of the EEG GUI.
% USAGE:    Click Data Setup: Structural in the EEG GUI.
% 
% DESCRIPTION: This file, in addition to datasetupT1.fig, is the file created by MATLAB's
% Graphic User Interface Design Environment (GUIDE) for the Data Setup portion of the GUI.
% It defines what is done when each button/checkbox/etc is pressed/changed in the GUI.

% Edit the above text to modify the response to help datasetupT1

% Last Modified by GUIDE v2.5 09-Nov-2016 11:38:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @datasetupT1_OpeningFcn, ...
                   'gui_OutputFcn',  @datasetupT1_OutputFcn, ...
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


% --- Executes just before datasetupT1 is made visible.
function datasetupT1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to datasetupT1 (see VARARGIN)
spmdir = fileparts(which('spm'));
handles.spmdir = spmdir;
    
if ~isempty(getappdata(0,'datasetup_vals'));
    tmp = getappdata(0,'datasetup_vals');
    set(handles.structdirtext, 'String', tmp.structdir);
    set(handles.t1prefixbox, 'String', tmp.t1prefix);
    if ~strcmp(tmp.t1type, '')
        switch tmp.t1type
            case 'raw'
                valtype = 2;
            case 'oriented'
                valtype = 3;
            case 'cropped-oriented'
                valtype = 4;
            case 'FSL-BET'
                valtype = 5;
        end
        set(handles.t1typedd, 'Value', valtype);
    end
    if ~strcmp(tmp.t1ext, '')
        switch tmp.t1ext
            case '.nii'
                valext = 2;
            case '.img'
                valext = 3;
        end
        set(handles.t1extdd, 'Value', valext);
    end
    handles.structdir = tmp.structdir;
    handles.t1prefix = tmp.t1prefix;
    handles.t1type = tmp.t1type;
    handles.t1prefix2 = tmp.t1prefix2;
    handles.t1suffix = tmp.t1suffix;
    handles.t1ext = tmp.t1ext;
    handles.T1subjs = tmp.T1subjs;
    handles.funcdir = tmp.funcdir;
    handles.spmdir = tmp.spmdir;
    handles.subject = tmp.subject;
    handles.run = tmp.run;
    handles.scan = tmp.scan;
    handles.subjs = tmp.subjs;
    guidata(hObject, handles);
    guidata(hObject, handles);
else
    handles.structdir = 'No Directory Selected!';
    handles.t1prefix = '';
    handles.t1type = '';
    handles.t1prefix2 = '';
    handles.t1suffix = '';
    handles.t1ext = '';
    handles.T1subjs = '';
    handles.funcdir = 'No Directory Selected!';
    handles.spmdir = '';
    handles.subject = '';
    handles.run = '';
    handles.scan = '';
    handles.subjs = '';
end

% Choose default command line output for datasetupT1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes datasetupT1 wait for user response (see UIRESUME)
% uiwait(handles.datasetupT1);

% --- Outputs from this function are returned to the command line.
function varargout = datasetupT1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in structdir.
function structdir_Callback(hObject, eventdata, handles)
% hObject    handle to structdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.structdir = uigetdir(pwd,' Subject T1 Directory');
if handles.structdir == 0
    handles.structdir = 'No Directory Selected!';
end
set(handles.structdirtext, 'String', handles.structdir)
guidata(hObject, handles);



function t1prefixbox_Callback(hObject, eventdata, handles)
% hObject    handle to t1prefixbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t1prefixbox as text
%        str2double(get(hObject,'String')) returns contents of t1prefixbox as a double
handles.t1prefix = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function t1prefixbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t1prefixbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in t1typedd.
function t1typedd_Callback(hObject, eventdata, handles)
% hObject    handle to t1typedd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns t1typedd contents as cell array
%        contents{get(hObject,'Value')} returns selected item from t1typedd

contents = cellstr(get(hObject,'String'));
handles.t1type = contents{get(hObject, 'Value')};

switch handles.t1type
    case 'raw'
        handles.t1prefix2 = '';
        handles.t1suffix = '';
    case 'oriented'
        handles.t1prefix2 = 'o';
        handles.t1suffix = '';
    case 'cropped-oriented'
        handles.t1prefix2 = 'co';
        handles.t1suffix = '';
    case 'FSL-BET'
        handles.t1prefix2 = '';
        handles.t1suffix = '_brain';
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function t1typedd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t1typedd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject, 'Value', 1)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in t1extdd.
function t1extdd_Callback(hObject, eventdata, handles)
% hObject    handle to t1extdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns t1extdd contents as cell array
%        contents{get(hObject,'Value')} returns selected item from t1extdd
contents = cellstr(get(hObject,'String'));
handles.t1ext = contents{get(hObject, 'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function t1extdd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t1extdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in segnew.
function segnew_Callback(hObject, eventdata, handles)
% hObject    handle to segnew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of segnew

% --- Executes on button press in segment.
function segment_Callback(hObject, eventdata, handles)
% hObject    handle to segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
T1subjs = dir([handles.structdir,'/',handles.subject, '*']);
T1subjs=T1subjs(~strncmpi('.',{T1subjs.name},1)); % Remove hidden folders (folders starting with '.')
sflag = [T1subjs.isdir]; % directories only
T1subjs = T1subjs(sflag); % directories only

run_struct = struct('structdir', handles.structdir, ...
    'spmdir', handles.spmdir, ...
    'T1subjs', T1subjs, ...
    't1prefix', handles.t1prefix, ...
    't1prefix2', handles.t1prefix2, ...
    't1suffix', handles.t1suffix, ...
    't1ext', handles.t1ext, ...
    'segment', 1, ...
    'segmentnew', get(handles.segnew, 'Value'), ...
    'slicetiming', 0, ...
    'realign', 0, ...
    'coreg', 0, ...
    'norm', 0, ...
    'smooth', 0, ...
    'newonly', 0);

if ~exist([pwd filesep 'Segmentation'], 'dir')
    mkdir Segmentation
end
cd Segmentation
segmentation(run_struct)
cd ..

h = msgbox('Segmentation Complete!');
waitfor(h)
guidata(hObject, handles);

% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
T1subjs = dir([handles.structdir,'/',handles.subject, '*']);
T1subjs=T1subjs(~strncmpi('.',{T1subjs.name},1)); % Remove hidden folders (folders starting with '.')
sflag = [T1subjs.isdir]; % directories only
T1subjs = T1subjs(sflag); % directories only

datasetup_vals = struct('structdir', handles.structdir, ...
    't1prefix', handles.t1prefix, ...
    't1type', handles.t1type, ...
    't1prefix2', handles.t1prefix2, ...
    't1suffix', handles.t1suffix, ...
    't1ext', handles.t1ext, ...
    'T1subjs', T1subjs, ...
    'funcdir', handles.funcdir, ...
    'spmdir', handles.spmdir, ...
    'subject', handles.subject, ...
    'run', handles.run, ...
    'scan', handles.scan, ...
    'subjs', handles.subjs);
setappdata(0, 'datasetup_vals', datasetup_vals);
close(handles.datasetup);


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.datasetup);


% --- Executes when user attempts to close datasetupT1.
function datasetup_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to datasetupT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
