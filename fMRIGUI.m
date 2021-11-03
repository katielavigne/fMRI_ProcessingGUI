function varargout = fMRIGUI(varargin)
% FMRIGUI MATLAB code for fMRIGUI.fig
%      FMRIGUI, by itself, creates a new FMRIGUI or raises the existing
%      singleton*.
%
%      H = FMRIGUI returns the handle to a new FMRIGUI or the handle to
%      the existing singleton*.
%
%      FMRIGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FMRIGUI.M with the given input arguments.
%
%      FMRIGUI('Property','Value',...) creates a new FMRIGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fMRIGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fMRIGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%% DOCUMENTATION
%
% AUTHOR: Katie Lavigne (lavigne.k@gmail.com)
% DATE: February 1st, 2016
% 
% FILE:     fMRIGUI.m (paired with fMRIGUI.fig)
% PURPOSE:  This is the GUIDE-created file for the EEG GUI.
% USAGE:    Type runEEG in the command window.
% 
% DESCRIPTION: This file, in addition to fMRIGUI.fig, is the file created by MATLAB's
% Graphic User Interface Design Environment (GUIDE). It defines what is done when each
% button/checkbox/etc is pressed/changed in the GUI and which external scripts to call.

% Edit the above text to modify the response to help fMRIGUI

% Last Modified by GUIDE v2.5 10-Nov-2016 11:02:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fMRIGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @fMRIGUI_OutputFcn, ...
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


% --- Executes just before fMRIGUI is made visible.
function fMRIGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fMRIGUI (see VARARGIN)

% Choose default command line output for fMRIGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fMRIGUI wait for user response (see UIRESUME)
% uiwait(handles.fMRIGUI);


% --- Outputs from this function are returned to the command line.
function varargout = fMRIGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in datasetupfMRI.
function datasetupfMRI_Callback(hObject, eventdata, handles)
% hObject    handle to datasetupfMRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datasetupfMRI
uiwait(datasetupfMRI);
datasetup_vals = getappdata(0,'datasetup_vals');
if isempty(datasetup_vals)
    return
end
if size(datasetup_vals.subjs,1) > 0
    set([handles.slicetiming, handles.realign, handles.norm, ...
        handles.smooth, handles.run, handles.runnew, handles.runall, ...
        handles.checkHM, handles.checknorm], 'enable', 'on');
else
    set([handles.slicetiming, handles.realign, handles.norm, ...
        handles.smooth, handles.run, handles.runnew, handles.runall, ...
        handles.checkHM, handles.checknorm], 'enable', 'off');
end

% --- Executes on button press in datasetupT1.
function datasetupT1_Callback(hObject, eventdata, handles)
% hObject    handle to datasetupT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datasetupT1
uiwait(datasetupT1);
datasetup_vals = getappdata(0,'datasetup_vals');
if isempty(datasetup_vals)
    return
end
if size(datasetup_vals.subjs,1) > 0 && size(datasetup_vals.T1subjs,1) > 0
    set(handles.coreg, 'enable', 'on');
else
    set(handles.coreg, 'enable', 'off');
end

% --- Executes when selected object is changed in runtype.
function runtype_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in runtype 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue, 'Tag')
    case 'runnew'
        handles.newonly = 1;
    case 'runall'
        handles.newonly = 0;
end
guidata(hObject, handles);


% --- Executes on button press in slicetiming.
function slicetiming_Callback(hObject, eventdata, handles)
% hObject    handle to slicetiming (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of slicetiming
slicetiming_on = get(hObject, 'Value');
if slicetiming_on == 1
    prompt = {'Number of slices:','TR:','Scan order:','Reference slice:'}; % Slice Timing Parameters
    title = 'Input Slice Timing Parameters';
    defaultanswer = {'35', '2', '1:2:35 2:2:34','19'}; % OTT/MCT study default parameters for UBC scanner
    parameters = inputdlg(prompt, title, [1, length(title)+50], defaultanswer);
    if ~isempty(parameters)
        handles.numslices = str2double(parameters{1});
        handles.TR = str2double(parameters{2});
        handles.scorder = str2num(parameters{3});
        handles.refslice = str2double(parameters{4});
    else
        set(handles.slicetiming, 'Value', 0);
    end
end
guidata(hObject, handles);


% --- Executes on button press in realign.
function realign_Callback(hObject, eventdata, handles)
% hObject    handle to realign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of realign


% --- Executes on button press in coreg.
function coreg_Callback(hObject, eventdata, handles)
% hObject    handle to coreg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of coreg



% --- Executes on button press in norm.
function norm_Callback(hObject, eventdata, handles)
% hObject    handle to norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of norm
norm_on = get(hObject ,'Value');
if norm_on == 1
    prompt = {'Voxel size:'}; % Normalization Parameters
    title = 'Input Normalization Parameters';
    defaultanswer = {'2 2 2'}; 
    parameters = inputdlg(prompt, title, [1, length(title)+50], defaultanswer);
    if ~isempty(parameters)
        handles.voxelsize= str2num(parameters{1});
    else
        set(handles.norm, 'Value', 0);
    end
end
guidata(hObject, handles);


% --- Executes on button press in smooth.
function smooth_Callback(hObject, eventdata, handles)
% hObject    handle to smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of smooth
smooth_on = get(hObject ,'Value');
if smooth_on == 1
    prompt = {'Kernel size:'}; % Normalization Parameters
    title = 'Input Smoothing Parameters';
    defaultanswer = {'6 6 6'}; 
    parameters = inputdlg(prompt, title, [1, length(title)+50], defaultanswer);
    if ~isempty(parameters)
        handles.kernelsize= str2num(parameters{1});
    else
        set(handles.smooth, 'Value', 0);
    end
end
guidata(hObject, handles);

% --- Executes on button press in checkHM.
function checkHM_Callback(hObject, eventdata, handles)
% hObject    handle to checkHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
InterfaceObj=findobj(fMRIGUI,'Enable','on');
datasetup_vals = getappdata(0,'datasetup_vals');
chk_struct = struct('funcdir', datasetup_vals.funcdir, ...
    'structdir', datasetup_vals.structdir, ...
    'spmdir', datasetup_vals.spmdir, ...
    'subject', datasetup_vals.subject, ...
    'subjs', datasetup_vals.subjs, ...
    'run', datasetup_vals.run, ...
    'scan', datasetup_vals.scan, ...
    't1prefix', datasetup_vals.t1prefix, ...
    't1prefix2', datasetup_vals.t1prefix2, ...
    't1suffix', datasetup_vals.t1suffix, ...
    't1ext', datasetup_vals.t1ext, ...
    'slicetiming', get(handles.slicetiming, 'Value'), ...
    'realign', get(handles.realign, 'Value'), ...
    'coreg', get(handles.coreg, 'Value'), ...
    'norm', get(handles.norm, 'Value'), ...
    'smooth', get(handles.smooth, 'Value'), ...
    'runnew', handles.runnew, ...
    'runall', handles.runall);

set(InterfaceObj,'Enable','off');
checkHM(chk_struct)
set(InterfaceObj,'Enable','on');

% --- Executes on button press in checknorm.
function checknorm_Callback(hObject, eventdata, handles)
% hObject    handle to checknorm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
InterfaceObj=findobj(fMRIGUI,'Enable','on');
datasetup_vals = getappdata(0,'datasetup_vals');
chk_struct = struct('funcdir', datasetup_vals.funcdir, ...
    'structdir', datasetup_vals.structdir, ...
    'spmdir', datasetup_vals.spmdir, ...
    'subject', datasetup_vals.subject, ...
    'subjs', datasetup_vals.subjs, ...
    'run', datasetup_vals.run, ...
    'scan', datasetup_vals.scan, ...
    't1prefix', datasetup_vals.t1prefix, ...
    't1prefix2', datasetup_vals.t1prefix2, ...
    't1suffix', datasetup_vals.t1suffix, ...
    't1ext', datasetup_vals.t1ext, ...
    'slicetiming', get(handles.slicetiming, 'Value'), ...
    'realign', get(handles.realign, 'Value'), ...
    'coreg', get(handles.coreg, 'Value'), ...
    'norm', get(handles.norm, 'Value'), ...
    'smooth', get(handles.smooth, 'Value'), ...
    'runnew', handles.runnew, ...
    'runall', handles.runall);

% set(InterfaceObj,'Enable','off');
checknorm(chk_struct)
% set(InterfaceObj,'Enable','on');

% --- Executes on button press in run. *************** UPDATE!!!! ****************
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)  
InterfaceObj=findobj(fMRIGUI,'Enable','on');
datasetup_vals = getappdata(0,'datasetup_vals');
run_struct = struct('funcdir', datasetup_vals.funcdir, ...
    'structdir', datasetup_vals.structdir, ...
    'spmdir', datasetup_vals.spmdir, ...
    'subject', datasetup_vals.subject, ...
    'subjs', datasetup_vals.subjs, ...
    'run', datasetup_vals.run, ...
    'scan', datasetup_vals.scan, ...
    't1prefix', datasetup_vals.t1prefix, ...
    't1prefix2', datasetup_vals.t1prefix2, ...
    't1suffix', datasetup_vals.t1suffix, ...
    't1ext', datasetup_vals.t1ext, ...
    'slicetiming', get(handles.slicetiming, 'Value'), ...
    'realign', get(handles.realign, 'Value'), ...
    'coreg', get(handles.coreg, 'Value'), ...
    'norm', get(handles.norm, 'Value'), ...
    'smooth', get(handles.smooth, 'Value'), ...
    'newonly', handles.newonly);

% set(InterfaceObj,'Enable','off');

preprocess_run(run_struct, handles);

h = msgbox('fMRI Preprocessing Complete!');
waitfor(h)
set([handles.slicetiming, handles.realign, handles.coreg, ...
    handles.norm, handles.smooth],'Value', 0);
guidata(hObject, handles);
set(InterfaceObj,'Enable','on');


% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear all application data
appdata = get(0,'ApplicationData');
fns = fieldnames(appdata);
for ii = 1:numel(fns)
    rmappdata(0,fns{ii});
end
close(gcf);
% set(0,'DefaultUicontrolBackgroundColor', [.94 .94 .94])


% --- Executes when user attempts to close fMRIGUI.
function fMRIGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fMRIGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% clear all application data
appdata = get(0,'ApplicationData');
fns = fieldnames(appdata);
for ii = 1:numel(fns)
    rmappdata(0,fns{ii});
end
delete(hObject);
% set(0,'DefaultUicontrolBackgroundColor', [.94 .94 .94])