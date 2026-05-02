%生成用于机器学习的训练样本
%with eeg
% by 吴健 XMU 
% 2018.9.19
%样本的尺寸

% function out_obj = WJ_gen_obj_eeg(slice)
clc
clear 
close all
row = 512;      %   row=440，图像fov为22cm，此时分辨率为0.5ms
col = row;
FOV=0.22;       %22cm
dirname='D:\MRiLab_master\Src\WJGCODE\D2\';
slice = 3;
fid_file_all1=dir([dirname,'*.T1']);    %list all files
fid_file_all2=dir([dirname,'*.T2']);    %list all files
fid_file_all3=dir([dirname,'*.m0']);    %list all files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%加载MRiLab模板
load('BrainHighResolution')
%修改参数
VObj.XDim = row;
VObj.YDim = col;
VObj.ZDim = slice;
VObj.XDimRes=FOV/row;
VObj.YDimRes=FOV/col;
VObj.ZDimRes=1e-3;
%读入Rho
Rho = zeros(row,col,slice);
%读入T1
T1 = zeros(row,col,slice);
%读入T2
T2 = zeros(row,col,slice);
%读入T2Star
T2Star = zeros(row,col,slice);
%读入ECon
ECon = zeros(row,col,slice);
%读入MassDen
MassDen =zeros(row,col,slice);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for loopi =  1:3%;length(fid_file_all2)
    %T1
    fid_file =[dirname,fid_file_all1(loopi).name];
    fip_dif=fopen(fid_file,'rb');
    [Array_2D_dif,num]=fread(fip_dif,inf,'double');    
    data_temp=Array_2D_dif(:,:);
    data_temp=reshape(data_temp,512,512);
    data_temp = abs(imresize(data_temp,[row,col])); 
    final_T1 = data_temp;
%T2
    fid_file =[dirname,fid_file_all2(loopi).name];
    fip_dif=fopen(fid_file,'rb');
    [Array_2D_dif,num]=fread(fip_dif,inf,'double');    
    data_temp=Array_2D_dif(:,:);
    data_temp=reshape(data_temp,512,512);
    data_temp = abs(imresize(data_temp,[row,col])); 
    final_T2 = data_temp;   

%M0
    fid_file =[dirname,fid_file_all3(loopi).name];
    fip_dif=fopen(fid_file,'rb');
    [Array_2D_dif,num]=fread(fip_dif,inf,'double');    
    data_temp=Array_2D_dif(:,:);
    data_temp=reshape(data_temp,512,512);
    data_temp = abs(imresize(data_temp,[row,col])); 
    final_Rho = data_temp;   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改Rho%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Rho(:,:,loopi) = final_Rho;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改T1%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    T1(:,:,loopi) = final_T1.*(final_Rho>0);%保证Rho为零的位置T1、T2为零
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改T2%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    T2(:,:,loopi) = final_T2.*(final_Rho>0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改T2Star%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %设计T2Star
    WJG_T2Star = final_T2;    %所有T2设为
    T2Star(:,:,loopi) = WJG_T2Star*0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改ECon%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %这部分代码可能要调整，数据结构与其他不同
    %设计ECon
    WJG_ECon = final_Rho*0;    %
    ECon(:,:,loopi) = WJG_ECon;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改MassDen%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %设计ECon
    WJG_MassDen = final_Rho*0;    %
    MassDen(:,:,loopi) = WJG_MassDen;
    disp(loopi)
end
    VObj.Rho = abs(Rho);VObj.T1 = abs(T1);VObj.T2 = abs(T2);VObj.T2Star = abs(T2Star);VObj.ECon = abs(ECon);VObj.MassDen = abs(MassDen);
VObj.XDimRes = FOV/row;
VObj.yDimRes = FOV/col;
out_obj = VObj;

save eegVObj.mat VObj
%