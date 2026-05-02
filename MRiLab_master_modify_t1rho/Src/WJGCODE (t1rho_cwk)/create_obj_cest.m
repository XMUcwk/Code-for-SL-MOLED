%create cest model for MRiLab
% by Angus XMU 
% 2018.10.13
clc
clear
close all
load('D:\MRiLab_master\Resources\VObj\WJG_CEST.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change Rho%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rho
Rho = VObj.Rho;
%
[row,col,slice,type] = size(Rho);
row = row/2;
col = col/2;
slice = 10;
%Rho
final_Rho = zeros(row,col,slice,type);
for loopj  = 1:type
    for loopi = 1:slice
        WJG_Rho = Rho(:,:,loopi,loopj)/2;
        WJG_Rho = imresize(WJG_Rho,[row,col],'nearest');
        final_Rho(:,:,loopi,loopj) = WJG_Rho;
    end
end
VObj.Rho = final_Rho;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change T1%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%T1
T1 = VObj.T1;
final_T1 = zeros(row,col,slice,type);
for loopj  = 1:type
    for loopi = 1:slice
        WJG_T1 = T1(:,:,loopi,loopj);
        WJG_T1 = imresize(WJG_T1,[row,col],'nearest');
        final_T1(:,:,loopi,loopj) = WJG_T1;
    end
end
VObj.T1 = final_T1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%T2%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%T2
T2 = VObj.T2;
final_T2 = zeros(row,col,slice,type);
for loopj  = 1:type
    for loopi = 1:slice
        WJG_T2 = T2(:,:,loopi,loopj);
        WJG_T2 = imresize(WJG_T2,[row,col],'nearest');
        final_T2(:,:,loopi,loopj) = WJG_T2;
    end
end
VObj.T2 = final_T2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%T2Star%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%T2Star
VObj.T2Star = final_T2/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ECon%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%K%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%K
K = VObj.K*2;
final_K = zeros(row,col,slice,4);
for loopj  = 1:4
    for loopi = 1:slice
        WJG_K = K(:,:,loopi,loopj);
        WJG_K = imresize(WJG_K,[row,col],'nearest');
        final_K(:,:,loopi,loopj) = WJG_K;
    end
end
VObj.K = final_K;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VObj.ChemShift = [0,0,600/7];
VObj.XDim=col;
VObj.YDim=row;
VObj.ZDim=slice;
save WJG_CEST_4tubes VObj



