%create model for MRiLab
% by Angus XMU 
% 2019.7.15
clear
clc

load('../../../BrainHighResolution')
%% parameters
row = 500;
col = 500;
slice = 150;
fov = 0.22;
fovz = 0.03; %3 cm
%% process
I1 = double(rgb2gray(imread('model.tif')));
I1 = (I1~=255);
I1 = imresize(I1,[row,col],'nearest');
[label, ~] = bwlabel(I1);
Rho_final = zeros(row,col,1);
T2_final = zeros(row,col,1);
T2star_final = zeros(row,col,1);
T1_final = zeros(row,col,1);
for loopi = 1:9
    mask = (label==loopi);
    Rho_temp = mask*1;
    T2_temp = mask.*((loopi-1)*0.02+0.02);%mask*0.02*loopi;
    T2star_temp = T2_temp;
    T1_temp = mask.*3;
    Rho_final = Rho_final+Rho_temp;
    T2_final = T2_final+T2_temp;
    T2star_final = T2star_final+T2star_temp;
    T1_final = T1_final+T1_temp;
end

VObj.Rho = repmat(Rho_final,[1,1,slice]);
VObj.T1 = repmat(T1_final,[1,1,slice]);
VObj.T2 = repmat(T2_final,[1,1,slice]);
VObj.T2Star = repmat(T2star_final,[1,1,slice]);
VObj.ECon = [];
VObj.MassDen = [];
VObj.XDim=row;
VObj.YDim=col;
VObj.ZDim=slice;
VObj.XDimRes = fov/row;
VObj.YDimRes = fov/col;
VObj.ZDimRes = fovz/slice;
save WJG4t2star_150slice_T2 VObj



