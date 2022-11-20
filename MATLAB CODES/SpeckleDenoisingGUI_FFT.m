function varargout = SpeckleDenoisingGUI_FFT(varargin)
% SPECKLEDENOISINGGUI_FFT MATLAB code for SpeckleDenoisingGUI_FFT.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpeckleDenoisingGUI_FFT_OpeningFcn, ...
                   'gui_OutputFcn',  @SpeckleDenoisingGUI_FFT_OutputFcn, ...
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


% --- Executes just before SpeckleDenoisingGUI_FFT is made visible.
function SpeckleDenoisingGUI_FFT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpeckleDenoisingGUI_FFT (see VARARGIN)

% Choose default command line output for SpeckleDenoisingGUI_FFT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpeckleDenoisingGUI_FFT wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpeckleDenoisingGUI_FFT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pause(1);
close();
close();

% --- Executes on button press in select_ip_img.
function select_ip_img_Callback(hObject, eventdata, handles)
% hObject    handle to select_ip_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname , path]=uigetfile('.jpg', 'Select an Image');
fname=strcat(path,fname);
I=imread(fname);
if size(I,3)== 3
    I=rgb2gray(I);
else
    I=I;
end
setappdata(0,'I',I);
axes(handles.axes1);
imshow(I);
v=0;
handles.v=v;
handles.I=I;
guidata(hObject,handles);

% --- Executes on button press in add_speckle.
function add_speckle_Callback(hObject, eventdata, handles)
% hObject    handle to add_speckle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
J=handles.I;
v=1;
I1=imnoise(J,'speckle',0.2);
axes(handles.axes1);
imshow(I1);
handles.I1=I1;
handles.v=v;
guidata(hObject,handles);

% --- Executes on button press in remove_speckle.
function remove_speckle_Callback(hObject, eventdata, handles)
% hObject    handle to remove_speckle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v=handles.v;
I=handles.I;
if v == 0
    noisyImage=I;
else
    I1=handles.I1;
    noisyImage=I1;
end

    %anisotropic diffusion filtering
J1=imdiffusefilt(noisyImage,'NumberOfIteration',10,'Connectivity','maximal','ConductionMethod','exponential');

    %2D Fourier Transform
Y = fft2(J1);
F_mag = log(1 + abs(Y));
Fou_Phase = angle(Y);

    %processing
Y1=imguidedfilter(F_mag);

    %inverse fourier transform
X = ifft2(Y1);
I4 = FrostFilter(J1,getnhood(strel('disk',5,0)));
 
sharpcoeff = [ 0 0 0; 0 1 0; 0 0 0];
I5 = imfilter(I4,sharpcoeff,'symmetric');
axes(handles.axes2);
imshow(I5);
 
peaksnr=psnr(I5,I);
meansqerror=immse(I5,I);
ssimval=ssim(I5,I);
set(handles.psnr_val,'String',num2str(peaksnr));
set(handles.mse_val,'String',num2str(meansqerror));
set(handles.ssim_val,'String',num2str(ssimval));

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=handles.I;
axes(handles.axes1);
imshow(a);
a1=ones(size(a));
axes(handles.axes2);
imshow(a1);
v=0;
handles.v=v;
guidata(hObject,handles);
h=0;
set(handles.psnr_val,'String',num2str(h));
set(handles.mse_val,'String',num2str(h));
set(handles.ssim_val,'String',num2str(h));

% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a2=handles.I;
a2=ones(size(a2));
axes(handles.axes1);
imshow(a2);
axes(handles.axes2);
imshow(a2);
v=0;
handles.v=v;
guidata(hObject,handles);
h=0;
set(handles.psnr_val,'String',num2str(h));
set(handles.mse_val,'String',num2str(h));
set(handles.ssim_val,'String',num2str(h))


% --- Executes during object creation, after setting all properties.
function psnr_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psnr_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function mse_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mse_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function ssim_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ssim_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
