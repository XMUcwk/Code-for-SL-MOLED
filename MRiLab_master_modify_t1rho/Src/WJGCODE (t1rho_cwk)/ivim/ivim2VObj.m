% generate VObj from ivim samples (lian xudong)
% creater angus 2019.6.24
clc
clear
close all
%% parameters
slice = 12;
output_channel = 3;
row =256;
col =256;
filename ='ivim1.charles';
%% load ivim model
fid = fopen(filename, 'r');
data_in = fread(fid,'double')';
ivim_data = reshape(data_in,[slice+output_channel,row,col]);
D = squeeze(ivim_data(13,:,:))/1000;
D_star = squeeze(ivim_data(14,:,:))/1000;
f = squeeze(ivim_data(15,:,:))/1000;
% load VObj
load('WJG_diffusion.mat')

VObj.WJG_ADC = imresize(D,[500,500],'nearest');
VObj.WJG_ADC_star = imresize(D_star,[500,500],'nearest');
VObj.WJG_F = imresize(f,[500,500],'nearest');
mask = VObj.WJG_ADC;
mask = mask>1e-5;
VObj.T1 = 2*mask;
VObj.T2 = 0.2*mask;
VObj.T2Star = VObj.T2;
VObj.Rho = 1*mask;
save('WJG_IVIM.mat','VObj')