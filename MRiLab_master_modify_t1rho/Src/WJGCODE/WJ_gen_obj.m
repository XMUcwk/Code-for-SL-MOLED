% generate deep learning samples 
% 2018.6.26 created by ANGUS XMU 
%  2018.11.18 add T2STAR
% 2018.12.3 generate samples from existing ones 

%generate geomotrary randomly 

% = Base+random  texture
function out_obj = WJ_gen_obj(slice,loopj)
%slice ; % the slice number
global VCtl;
rng('shuffle');%the random seed
dirname = VCtl.FILE_path;
% dirs=dir([dirname,'*.mat']);
% filename = [dirname,dirs(loopj).name];
filename = [dirname,num2str(loopj),'.mat'];

load(filename);
VObj.XDimRes = VCtl.FOVFreq/VObj.XDim;
VObj.YDimRes = VCtl.FOVPhase/VObj.YDim;
VObj.T1 = VObj.T1 ;
VObj.T2 = VObj.T2 ;
VObj.T2Star = VObj.T2Star ;
out_obj = VObj;
