% generate deep learning samples 
% 2018.6.26 created by ANGUS XMU 
%  2018.11.18 add T2STAR
% 2018.12.3 generate samples from existing ones 
% 2019.11.7 for slice profile
%generate geomotrary randomly 

% = Base+random  texture
function out_obj = WJ_gen_obj4ms(slice,loopj)
%slice ; % the slice number
% 

global VCtl;
rng('shuffle');%the random seed
dirname = VCtl.FILE_path;
dirs=dir([dirname,'*.mat']);
filename = [dirname,dirs(loopj).name];

load(filename);

VObj.ZDimRes = 4e-5; 
VObj.ZDim = 150;
VObj.XDimRes = VCtl.FOVFreq/VObj.XDim;
VObj.YDimRes = VCtl.FOVPhase/VObj.YDim;
VObj.T2 = repmat(VObj.T2,[1,1,VObj.ZDim]) ;
VObj.T2Star = repmat(VObj.T2Star,[1,1,VObj.ZDim]);
VObj.T1 = repmat(VObj.T1,[1,1,VObj.ZDim]);
VObj.Rho = repmat(VObj.Rho,[1,1,VObj.ZDim]);
out_obj = VObj;
