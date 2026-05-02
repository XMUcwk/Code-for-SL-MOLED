%without gaussian filter
% generate deep learning samples 
% 2018.6.26 created by ANGUS XMU 
% 2018.11.18 add T2STAR
% 2019.5.20 add ADC
% 2019.6.29 add random ADC range

%generate geomotrary randomly 

% = Base+random  texture
function out_obj = WJ_gen_obj2(loopj)
% loopj : the number of samples you want to generate
% you should change some paramerers
% 1. dirname: this directory should contain some images, you can download
% from the website
% 2. save_file: this parameter determine the output filename of your
% generated samples
%3. other parameter can be modified to adapt to your task.
addpath(genpath('/data3/cwk/Phantom_for_water_fat_separation_oled_single_peak/tools'))
warning ('off')
%slice ; % the slice number
global VCtl;
rng('shuffle');%the random seed
idx_num = loopj;
slice =1;
ratio =0.2;%0.6;    % the weighting of texture
row = 500;      %   row=440 fov=22cm the resolution 0.5ms
col = row;
fov = 0.22;     % Field of view
num = 200;      % the number of mask
sigma = 2;    % used for gaussian filter
T2max = 600;  % the maximum T2 value   350 changge to 20 cwk 
ADC_max = 5e-3;   % the maximum ADC value 3.5e
gausFilter=fspecial('gaussian',[8 8],sigma);
Mxdims = [row,col,1];  %row,col,slice
DimRes = fov /row;
Hz_per_PPM = 150;   % 7T
GAMAR = 267522120;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%generate samples with optical images
dirname='/data3/cwk/image2/';
dirs=dir([dirname,'*.jpg']);
samples=length(dirs);
load('brain_mask');
mask_num=size(brain_mask,3);
%%%%%%%%%%%%%%%%load an MRiLab mask
load('MY_OBJ1')
VObj.XDimRes=row;
VObj.YDimRes=col;
VObj.ZDimRes=slice;
VObj.XDimRes=fov/row;
VObj.YDimRes=fov/col;
VObj.ZDimRes=1e-3;
%Rho
Rho = zeros(row,col,slice);
%T1
T1 = zeros(row,col,slice);
%T2
T2 = zeros(row,col,slice);
% T2STAR
T2STAR = zeros(row,col,slice);
% ADC
ADC = zeros(row,col,slice);
% T1rho
T1rho= zeros(row,col,slice);
%ECon
ECon = zeros(row,col,slice,3);
% MassDen
MassDen =zeros(row,col,slice);
max_slice = min([samples,mask_num,slice]);% samples:the number of pictures(2201)
% mask_num:the number of different masks(161)
% slice: the number of slices(1)
% for loopi = 1:max_slice
 for loopi = 1
    sel_frame = randi([1,mask_num],1); 
    % the random shape should not be appear in the board of the fov
    fill=33;
    fill1=randi([10,2*fill-10],1);
    fill2=randi([10,2*fill-10],1);
    temp_brain_mask = brain_mask(:,:,mod(sel_frame,mask_num)+1);% 
    temp_brain_mask=[zeros(fill1,256);temp_brain_mask;zeros(2*fill-fill1,256)];
    temp_brain_mask=[zeros(256+2*fill,fill2),temp_brain_mask,zeros(256+2*fill,2*fill-fill2)];
    temp_brain_mask = imresize(temp_brain_mask,[row,col],'nearest');
    range = find(sum(temp_brain_mask,2)>0);
    top = range(1)+row/20;
    bottom = range(end)-row/10;
    range = find(sum(temp_brain_mask,1)>0);
    left = range(1)+col/20;
    right = range(end)-col/10;
    range = [top,bottom,left,right];
    %mask
    temp_mask = zeros(row,col);
    final_T1 = zeros(row,col);
    final_T2 = zeros(row,col);
    final_T2STAR = zeros(row,col);
    final_Rho = zeros(row,col);
    final_ADC = zeros(row,col);
    final_T1rho = zeros(row,col);
    thres_area = sum(temp_brain_mask(:))*0.1;
%     T2max_temp = unifrnd(100,T2max);
    T2max_temp =T2max;% unifrnd(650,T2max);
%     ADC_max_temp = unifrnd(0.5e-3,ADC_max);
    ADC_max_temp = ADC_max;%unifrnd(0.69e-3,ADC_max);
    
    for loopj = 1:num
        [final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,final_T1rho,temp_mask] =  WJGshape2(final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,final_T1rho,temp_mask,row,col,dirname,dirs,1,ratio,range,T2max_temp,ADC_max_temp);%circle
        [final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,final_T1rho,temp_mask] =  WJGshape2(final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,final_T1rho,temp_mask,row,col,dirname,dirs,3,ratio,range,T2max_temp,ADC_max_temp);%square
        [final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,final_T1rho,temp_mask] =  WJGshape2(final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,final_T1rho,temp_mask,row,col,dirname,dirs,4,ratio,range,T2max_temp,ADC_max_temp);% triangle  
        residual_mask = temp_brain_mask.*abs(temp_mask-temp_brain_mask);%%
        if (sum(residual_mask(:))<thres_area) 
            break;
        end
    end
% %%%%%%
% figure;imagesc(final_T2);colormap jet;title('final_T2');
% figure;imagesc(final_Rho);colormap jet;title('final_Rho');    
% figure;imagesc(final_ADC);colormap jet;title('final_ADC');       
%% T1
    final_T1 = 1000.*temp_brain_mask;%final_T1.*temp_brain_mask;
    final_T1 = final_T1/1000;      %T1
 %% T2    0~2.2s
    final_T2 = final_T2.*temp_brain_mask;
%         final_T2 = abs(imfilter(final_T2,gausFilter,'replicate'));
%         final_T2 = medfilt2(final_T2,[filter_size,filter_size]);
    final_T2 = final_T2/1000;    %T2

%% T2star    
    final_T2STAR = final_T2STAR.*temp_brain_mask;
    final_T2STAR = final_T2STAR/1000;    %T2
    final_T2STAR = (final_T2STAR>=final_T2).*final_T2+(final_T2STAR<final_T2).*final_T2STAR;    %T2star should be less than T2

 %% Rho	0-1
    final_Rho = final_Rho.*temp_brain_mask;
    final_Rho = final_Rho*1;
    
 %% ADC	
    final_ADC = final_ADC.*temp_brain_mask;
 %% T1rho    
    final_T1rho = final_T1rho.*temp_brain_mask;
%         final_T2 = abs(imfilter(final_T2,gausFilter,'replicate'));
%         final_T2 = medfilt2(final_T2,[filter_size,filter_size]);
    final_T1rho = final_T1rho/1000;    %T1rho    
%% generate models
    Rho(:,:,loopi) = final_Rho;
    T1(:,:,loopi) = final_T1.*(final_Rho>0);     % setting all T1=2s
    T2(:,:,loopi) = final_T2.*(final_Rho>0);
    T2STAR(:,:,loopi) = final_T2STAR.*(final_Rho>0);%	
    ADC(:,:,loopi) = final_ADC.*(final_ADC>0);
    T1rho(:,:,loopi) = final_T1rho.*(final_T1rho>0);
    ECon = [];
    MassDen  = [];
%     disp(loopi)
%     subplot(231);imagesc(T1,[0,2]);colormap(jet);
%     subplot(232);imagesc(final_T2,[0,0.3]); colormap(jet);
%     subplot(233);imagesc(final_Rho,[0,1]); colormap(jet);
%     subplot(234);imagesc(final_T2STAR,[0,0.3]);colormap(jet);
%     subplot(235);imagesc(final_ADC);colormap(jet);
 end
  [VMmg.xgrid,VMmg.ygrid,VMmg.zgrid] = meshgrid((-(Mxdims(2)-1)/2)*DimRes:DimRes:((Mxdims(2)-1)/2)*DimRes,...
                                               (-(Mxdims(1)-1)/2)*DimRes:DimRes:((Mxdims(1)-1)/2)*DimRes,...
                                               (-(Mxdims(3)-1)/2)*DimRes:DimRes:((Mxdims(3)-1)/2)*DimRes);
dB0 = Mag_WW_LSM_CEST(VMmg)*GAMAR/Hz_per_PPM; 
VObj.B0 = dB0;
VObj.Rho = abs(Rho);
VObj.T1 = abs(T1);
VObj.T2 = abs(T2);
VObj.T2Star = abs(T2STAR);
VObj.ECon = abs(ECon);
VObj.MassDen = abs(MassDen);
VObj.WJG_ADC = abs(ADC);
VObj.T1rho = abs(T1rho);
out_obj = VObj;

save_file = ['/data3/cwk/t1rho/t1rho_template_2022.01.05/',num2str(idx_num)];
save(save_file,'VObj')
            
clear  'brain_mask'
