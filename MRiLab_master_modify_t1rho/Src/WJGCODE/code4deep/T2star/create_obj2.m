%create model for MRiLab
% by Angus XMU 
% 2019.10.20
% one slice of the brain
clear
clc

load('../../BrainHighResolution')
%% parameters
row = 500;
col = 500;
slice = 1;
fov = 0.22;
%% process
Rho_final = zeros(row,col,slice);
T2_final = zeros(row,col,slice);
T2Star_final = zeros(row,col,slice);
T1_final = zeros(row,col,slice);
for loopi = 1:slice
    Rho_temp = imresize(VObj.Rho(:,:,90),2,'nearest');
    Rho_final = padarray(Rho_temp,[(row-size(Rho_temp,1))/2,(col-size(Rho_temp,2))/2],0,'both');
    T1_temp = imresize(VObj.T1(:,:,90),2,'nearest');
    T1_final = padarray(T1_temp,[(row-size(T1_temp,1))/2,(col-size(T1_temp,2))/2],0,'both'); 
    T2_temp = imresize(VObj.T2(:,:,90),2,'nearest');
    T2_final = padarray(T2_temp,[(row-size(T2_temp,1))/2,(col-size(T2_temp,2))/2],0,'both');   
    T2_final = (T2_final>0.2).*0.2+(T2_final<=0.2).*T2_final;
    T2Star_temp = imresize(VObj.T2Star(:,:,90),2,'nearest');
    T2Star_final = padarray(T2Star_temp,[(row-size(T2Star_temp,1))/2,(col-size(T2Star_temp,2))/2],0,'both');       
    T2Star_final = (T2Star_final>0.2).*0.2+(T2Star_final<=0.2).*T2Star_final;
end

VObj.Rho = Rho_final;
VObj.T1 = T1_final;
VObj.T2 = T2_final;
VObj.T2Star = T2Star_final;
VObj.ECon = [];
VObj.MassDen = [];
VObj.XDim=row;
VObj.YDim=col;
VObj.ZDim=slice;
VObj.XDimRes = fov/row;
VObj.YDimRes = fov/col;
save WJG4t2star_brain VObj



