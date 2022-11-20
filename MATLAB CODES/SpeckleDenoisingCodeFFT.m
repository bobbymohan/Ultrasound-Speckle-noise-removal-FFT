clc;
clear all;
close all;

%getting an input image 

[fname , path]=uigetfile('.jpg', 'Select an Image');
fname=strcat(path,fname);
I=imread(fname);
if size(I,3)== 3
    I=rgb2gray(I);
else
    I=I;
end
figure, 
imshow(I);
title('Input Ultrasound Image');

%anisotropic diffusion filtering

J1=imdiffusefilt(I,'NumberOfIteration',10,'Connectivity','maximal','ConductionMethod','exponential');
figure,imshow(J1);
title('Anisotropic Diffusion Filtered Image');

% 2D fourier transform

Y = fft2(J1);
F_mag = log(1 + abs(Y));
Fou_Phase = angle(Y);
figure,
imagesc(fftshift(F_mag)); 
title('Fourier Transform');

%processing in freqquency domain

Y1=imguidedfilter(F_mag);
figure, 
imagesc(abs(fftshift(Y)));
title('Processed Image');

%inverse fourier transform
X = ifft2(Y1);
I4 = FrostFilter(J1,getnhood(strel('disk',2,0)));

sharpcoeff = [ 0 0 0; 0 1 0; 0 0 0];
I5 = imfilter(I4,sharpcoeff,'symmetric');
figure, 
imshow(I5);
title('Denoised Image');

%performance verification

peaksnr=psnr(I5,I);
meansqerror=immse(I5,I);
ssimval=ssim(I5,I);