%create model for MRiLab
% by Angus XMU 
% 2019.7.15
clear
clc

load('../../BrainHighResolution')
%% parameters
row = 2;
col = 2;
slice = 2000;
fov = 0.02;
%% process
Rho_final = ones(row,col,slice);
T2_final = ones(row,col,slice)*2;
T2star_final = ones(row,col,slice)*2;
T1_final = ones(row,col,slice)*2;


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
save WJG_bar VObj



