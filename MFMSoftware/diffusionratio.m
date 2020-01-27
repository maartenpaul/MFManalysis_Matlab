function varargout = diffusionratio(varargin)
% DIFFUSIONRATIO MATLAB code for diffusionratio.fig
%      DIFFUSIONRATIO, by itself, creates a new DIFFUSIONRATIO or raises the existing
%      singleton*.
%
%      H = DIFFUSIONRATIO returns the handle to a new DIFFUSIONRATIO or the handle to
%      the existing singleton*.
%
%      DIFFUSIONRATIO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIFFUSIONRATIO.M with the given input arguments.
%
%      DIFFUSIONRATIO('Property','Value',...) creates a new DIFFUSIONRATIO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before diffusionratio_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to diffusionratio_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help diffusionratio

% Last Modified by GUIDE v2.5 29-Mar-2018 15:12:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @diffusionratio_OpeningFcn, ...
                   'gui_OutputFcn',  @diffusionratio_OutputFcn, ...
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


% --- Executes just before diffusionratio is made visible.
function diffusionratio_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to diffusionratio (see VARARGIN)

% Choose default command line output for diffusionratio
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes diffusionratio wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = diffusionratio_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in choosefile.
function choosefile_Callback(hObject, eventdata, handles)
% hObject    handle to choosefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filelist,pathname] = uigetfile('*.mat','Choose analyzed tracked .mat files','Multiselect','on');
if ~iscell(filelist)
    filelist = {filelist};
end
setappdata(handles.choosefile,'pathname',pathname);
setappdata(handles.choosefile,'filelist',filelist);
set(handles.files,'String',filelist);
cd(pathname);

% --- Executes on selection change in files.
function files_Callback(hObject, eventdata, handles)
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from files


% --- Executes during object creation, after setting all properties.
function files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotdata.
function plotdata_Callback(hObject, eventdata, handles)
% hObject    handle to plotdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname = getappdata(handles.choosefile,'pathname');
filelist = getappdata(handles.choosefile,'filelist');
numfiles = length(filelist);
plotparam = get(handles.chooseparam,'Value');
data = [];
for a = 1:numfiles
    disp(['Loading file: ' filelist{a}]);
    output = load(fullfile(pathname,filelist{a}));
    output = output.output;
    if plotparam == 1
        data = [data;output.D]; %#ok<AGROW>
    elseif plotparam == 2
        data = [data;output.alpha]; %#ok<AGROW>
    end
end

hardcap = 10;
data = data(data<=hardcap);
setappdata(handles.plotdata,'data',data);
mindata = min(data);
maxdata = max(data);
meddata = median(data);
set(handles.maxval,'Min',mindata);
set(handles.maxval,'Max',maxdata);
set(handles.maxval,'Value',maxdata);
set(handles.maxvalue,'String',maxdata);
set(handles.cutoff,'Min',mindata);
set(handles.cutoff,'Max',maxdata);
set(handles.cutoff,'Value',meddata);
set(handles.cutoffvalue,'String',meddata);
plotdata = data(data<=maxdata);
axes(handles.axes1);
cla;
numbins = str2double(get(handles.numbins,'String'));
if numbins == 0
    histogram(plotdata);
    [N,X] = histcounts(plotdata);
elseif numbins > 0
    hist(plotdata,numbins);
    [N,X] = hist(plotdata,numbins);
end
    
if plotparam == 1
    xlabel('Diffusion Constant [um^2/s]');
elseif plotparam == 2
    xlabel('Alpha Value');
end
ylabel('Frequency');
line([meddata meddata],[0 max(N)],'Color','red','LineWidth',2);
numbelow = sum(data<=meddata);
numabove = sum(data>meddata);
dataratio = numabove/numbelow;
set(handles.ratioval,'String',dataratio);
setappdata(handles.saveresults,'plotdata',[N' X']);


% --- Executes on selection change in chooseparam.
function chooseparam_Callback(hObject, eventdata, handles)
% hObject    handle to chooseparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chooseparam contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chooseparam


% --- Executes during object creation, after setting all properties.
function chooseparam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chooseparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function maxval_Callback(hObject, eventdata, handles)
% hObject    handle to maxval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data = getappdata(handles.plotdata,'data');
maxvalue = get(handles.maxval,'Value');
set(handles.cutoff,'Max',maxvalue);
cutoff = get(handles.cutoff,'Value');
plotparam = get(handles.chooseparam,'Value');
set(handles.maxvalue,'String',maxvalue);
set(handles.cutoffvalue,'String',cutoff);
plotdata = data(data<=maxvalue);
axes(handles.axes1);
cla;
numbins = str2double(get(handles.numbins,'String'));
if numbins == 0
    histogram(plotdata);
    [N,X] = histogram(plotdata);
elseif numbins > 0
    hist(plotdata,numbins);
    [N,X] = hist(plotdata,numbins);
end
if plotparam == 1
    xlabel('Diffusion Constant [um^2/s]');
elseif plotparam == 2
    xlabel('Alpha Value');
end
ylabel('Frequency');
line([cutoff cutoff],[0 max(N)],'Color','red','LineWidth',2);
numbelow = sum(plotdata<=cutoff);
numabove = sum(plotdata>cutoff);
dataratio = numabove/numbelow;
set(handles.ratioval,'String',dataratio);
setappdata(handles.saveresults,'plotdata',[N' X']);


% --- Executes during object creation, after setting all properties.
function maxval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function cutoff_Callback(hObject, eventdata, handles)
% hObject    handle to cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data = getappdata(handles.plotdata,'data');
maxvalue = get(handles.maxval,'Value');
set(handles.cutoff,'Max',maxvalue);
cutoff = get(handles.cutoff,'Value');
plotparam = get(handles.chooseparam,'Value');
set(handles.maxvalue,'String',maxvalue);
set(handles.cutoffvalue,'String',cutoff);
plotdata = data(data<=maxvalue);
axes(handles.axes1);
cla;
numbins = str2double(get(handles.numbins,'String'));
if numbins == 0
    histogram(plotdata);
    [N,X] = histogram(plotdata);
elseif numbins > 0
    hist(plotdata,numbins);
    [N,X] = hist(plotdata,numbins);
end
if plotparam == 1
    xlabel('Diffusion Constant [um^2/s]');
elseif plotparam == 2
    xlabel('Alpha Value');
end
ylabel('Frequency');
line([cutoff cutoff],[0 max(N)],'Color','red','LineWidth',2);
numbelow = sum(plotdata<=cutoff);
numabove = sum(plotdata>cutoff);
dataratio = numabove/numbelow;
set(handles.ratioval,'String',dataratio);
setappdata(handles.saveresults,'plotdata',[N' X']);

% --- Executes during object creation, after setting all properties.
function cutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function maxvalue_Callback(hObject, eventdata, handles)
% hObject    handle to maxvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxvalue as text
%        str2double(get(hObject,'String')) returns contents of maxvalue as a double
data = getappdata(handles.plotdata,'data');
maxvalue = str2double(get(handles.maxvalue,'String'));
if maxvalue >= 1e12
    error('Max value too high!');
end
set(handles.maxval,'Max',1e12);
set(handles.maxval,'Value',maxvalue);
set(handles.maxval,'Max',1.5*maxvalue);
cutoff = get(handles.cutoff,'Value');
plotparam = get(handles.chooseparam,'Value');
plotdata = data(data<=maxvalue);
axes(handles.axes1);
cla;
numbins = str2double(get(handles.numbins,'String'));
if numbins == 0
    histogram(plotdata);
    [N,X] = histogram(plotdata);
elseif numbins > 0
    hist(plotdata,numbins);
    [N,X] = hist(plotdata,numbins);
end
if plotparam == 1
    xlabel('Diffusion Constant [um^2/s]');
elseif plotparam == 2
    xlabel('Alpha Value');
end
ylabel('Frequency');
line([cutoff cutoff],[0 max(N)],'Color','red','LineWidth',2);
numbelow = sum(plotdata<=cutoff);
numabove = sum(plotdata>cutoff);
dataratio = numabove/numbelow;
set(handles.ratioval,'String',dataratio);
setappdata(handles.saveresults,'plotdata',[N' X']);

% --- Executes during object creation, after setting all properties.
function maxvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cutoffvalue_Callback(hObject, eventdata, handles)
% hObject    handle to cutoffvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cutoffvalue as text
%        str2double(get(hObject,'String')) returns contents of cutoffvalue as a double
data = getappdata(handles.plotdata,'data');
maxvalue = str2double(get(handles.maxvalue,'String'));
cutoff = str2double(get(handles.cutoffvalue,'String'));
if cutoff>=1e12
    error('Cutoff value too high!');
end
set(handles.cutoff,'Max',1e12);
set(handles.cutoff,'Value',cutoff);
set(handles.cutoff,'Max',1.5*cutoff);
plotparam = get(handles.chooseparam,'Value');
plotdata = data(data<=maxvalue);
axes(handles.axes1);
cla;
numbins = str2double(get(handles.numbins,'String'));
if numbins == 0
    histogram(plotdata);
    [N,X] = histogram(plotdata);
elseif numbins > 0
    hist(plotdata,numbins);
    [N,X] = hist(plotdata,numbins);
end
if plotparam == 1
    xlabel('Diffusion Constant [um^2/s]');
elseif plotparam == 2
    xlabel('Alpha Value');
end
ylabel('Frequency');
line([cutoff cutoff],[0 max(N)],'Color','red','LineWidth',2);
numbelow = sum(plotdata<=cutoff);
numabove = sum(plotdata>cutoff);
dataratio = numabove/numbelow;
set(handles.ratioval,'String',dataratio);
setappdata(handles.saveresults,'plotdata',[N' X']);

% --- Executes during object creation, after setting all properties.
function cutoffvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutoffvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveresults.
function saveresults_Callback(hObject, eventdata, handles)
% hObject    handle to saveresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
results.data = getappdata(handles.plotdata,'data');
results.maxvalue = get(handles.maxval,'Value');
results.cutoffvalue = get(handles.cutoff,'Value');
results.plotdata = getappdata(handles.saveresults,'plotdata');
results.ratiovalue = str2double(get(handles.ratioval,'String')); %#ok<STRNU>
[filesave,pathsave] = uiputfile('*.mat','Save Results As...');
save(fullfile(pathsave,filesave),'results');



function numbins_Callback(hObject, eventdata, handles)
% hObject    handle to numbins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numbins as text
%        str2double(get(hObject,'String')) returns contents of numbins as a double
data = getappdata(handles.plotdata,'data');
maxvalue = str2double(get(handles.maxvalue,'String'));
cutoff = str2double(get(handles.cutoffvalue,'String'));
plotparam = get(handles.chooseparam,'Value');
plotdata = data(data<=maxvalue);
axes(handles.axes1);
cla;
numbins = str2double(get(handles.numbins,'String'));
if numbins == 0
    histogram(plotdata);
    [N,X] = histogram(plotdata);
elseif numbins > 0
    hist(plotdata,numbins);
    [N,X] = hist(plotdata,numbins);
end
if plotparam == 1
    xlabel('Diffusion Constant [um^2/s]');
elseif plotparam == 2
    xlabel('Alpha Value');
end
ylabel('Frequency');
line([cutoff cutoff],[0 max(N)],'Color','red','LineWidth',2);
numbelow = sum(plotdata<=cutoff);
numabove = sum(plotdata>cutoff);
dataratio = numabove/numbelow;
set(handles.ratioval,'String',dataratio);
setappdata(handles.saveresults,'plotdata',[N' X']);

% --- Executes during object creation, after setting all properties.
function numbins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numbins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
