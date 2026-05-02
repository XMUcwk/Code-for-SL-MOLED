%create model for MRiLab
% by Angus XMU 
% 2019.7.15
clear
clc

load('../../BrainHighResolution')
%% parameters
row = 500;
col = 500;
slice = 1;
fov = 0.22;
%% process
I1 = double(rgb2gray(imread('model.tif')));
I1 = (I1~=255);
I1 = imresize(I1,[row,col],'nearest');
[label, ~] = bwlabel(I1);
Rho_final = zeros(row,col,slice);
T2_final = zeros(row,col,slice);
T2star_final = zeros(row,col,slice);
T1_final = zeros(row,col,slice);
for loopi = 1:9
    mask = (label==loopi);
    Rho_temp = mask*1;
    T2_temp = 0.2*mask;%mask*0.02*loopi;
    T2star_temp = mask*0.02*loopi;
    T1_temp = mask*2;
    
    Rho_final = Rho_final+Rho_temp;
    T2_final = T2_final+T2_temp;
    T2star_final = T2star_final+T2star_temp;
    T1_final = T1_final+T1_temp;
end

VObj.Rho = Rho_final;
VObj.T1 = T1_final;
VObj.T2 = T2_final;
VObj.T2Star = T2star_final;
VObj.ECon = [];
VObj.MassDen = [];
VObj.XDim=row;
VObj.YDim=col;
VObj.ZDim=slice;
VObj.XDimRes = fov/row;
VObj.YDimRes = fov/col;
save WJG4t2star VObj



