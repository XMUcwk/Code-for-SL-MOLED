%with gaussian filter
% generate deep learning samples 
% 2018.6.26 created by ANGUS XMU 
%  2018.11.18 add T2STAR
% 2019.5.20 add ADC


%generate geomotrary randomly 

% = Base+random  texture
function out_obj = WJ_gen_obj1(slice,loopj)
warning ('off')
%slice ; % the slice number
global VCtl;
rng('shuffle');%the random seed
a=loopj;
ratio=0.8;
row = 500;      %   row=440 fov=22cm the resolution 0.5ms
col = row;
fov = 0.22;
num = 200;      % the number of mask
sigma = 2;    % used for gaussian filter
T2max =1200;
gausFilter = fspecial('gaussian',[8 8],sigma);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%generate samples with optical images
% dirname = VCtl.FILE_path;
dirname = '/data3/wj/image/';
dirs=dir([dirname,'*.jpg']);
samples = length(dirs);
load('brain_mask');
mask_num = size(brain_mask,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%load an MRiLab mask
load('MY_OBJ1')
%
VObj.XDim = row;
VObj.YDim = col;
VObj.ZDim = slice;
VObj.XDimRes = fov/row;
VObj.YDimRes = fov/col;
VObj.ZDimRes=1e-3;
% Rho
Rho = zeros(row,col,slice);
% T1
T1 = zeros(row,col,slice);
% T2
T2 = zeros(row,col,slice);
% T2STAR
T2STAR = zeros(row,col,slice);
% ADC
ADC = zeros(row,col,slice);
%ECon
ECon = zeros(row,col,slice,3);
% MassDen
MassDen =zeros(row,col,slice);
max_slice = min([samples,mask_num,slice]);% 
for loopi = 1:max_slice
    sel_frame = randi([1,mask_num],1); 
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
    %T1	0~5s
    temp_mask = zeros(row,col);
    final_T1 = zeros(row,col);
    final_T2 = zeros(row,col);
    final_T2STAR = zeros(row,col);
    final_Rho = zeros(row,col);
    final_ADC = zeros(row,col);
    thres_area = sum(temp_brain_mask(:))*0.1;
    T2max_temp = unifrnd(600,T2max);
    for loopj = 1:num
        [final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,temp_mask] =  WJGshape2(final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,temp_mask,row,col,dirname,dirs,1,ratio,range,T2max_temp);%circle
        [final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,temp_mask] =  WJGshape2(final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,temp_mask,row,col,dirname,dirs,3,ratio,range,T2max_temp);%square
        [final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,temp_mask] =  WJGshape2(final_T1,final_T2,final_T2STAR,final_Rho,final_ADC,temp_mask,row,col,dirname,dirs,4,ratio,range,T2max_temp);% triangle  
        residual_mask = temp_brain_mask.*abs(temp_mask-temp_brain_mask);%%
        if (sum(residual_mask(:))<thres_area) 
            break;
        end
    end

%% T1
    final_T1 = final_T1.*temp_brain_mask;
    final_T1 = final_T1/1000;      %T1
    final_T1 = imresize(imresize(final_T1,0.5,'bilinear'),2,'bilinear');
 %% T2    0~2.2s
    final_T2 = final_T2.*temp_brain_mask;
%         final_T2 = abs(imfilter(final_T2,gausFilter,'replicate'));
%         final_T2 = medfilt2(final_T2,[filter_size,filter_size]);
    final_T2 = final_T2/1000;    %T2
    final_T2 = imresize(imresize(final_T2,0.5,'bilinear'),2,'bilinear');
    final_T2 = abs(imfilter(final_T2,gausFilter,'replicate'));

%% T2star    
    final_T2STAR = final_T2STAR.*temp_brain_mask;
    final_T2STAR = final_T2STAR/1000;    %T2
    final_T2STAR = imresize(imresize(final_T2STAR,0.5,'bilinear'),2,'bilinear');
    final_T2STAR = (final_T2STAR>=final_T2).*final_T2+(final_T2STAR<final_T2).*final_T2STAR;    %T2star should be less than T2
    final_T2STAR = abs(imfilter(final_T2STAR,gausFilter,'replicate'));

 %% Rho	0-1
    final_Rho = final_Rho.*temp_brain_mask;
    final_Rho = final_Rho*1;
    final_Rho = imresize(imresize(final_Rho,0.5,'bilinear'),2,'bilinear');
    final_Rho = abs(imfilter(final_Rho,gausFilter,'replicate'));
    
 %% ADC	
    final_ADC = final_ADC.*temp_brain_mask;
    final_ADC = imresize(imresize(final_ADC,0.5,'bilinear'),2,'bilinear');
    final_ADC = abs(imfilter(final_ADC,gausFilter,'replicate'));
%         subplot(133);imshow(final_Rho,[]); colormap(jet);title('Rho');pause(0.001) 
%% generate models
    Rho(:,:,loopi) = final_Rho;
    T1(:,:,loopi) = ones(row,col)*2.*(final_Rho>0);     % setting all T1=2s
    T2(:,:,loopi) = final_T2.*(final_Rho>0);
    T2STAR(:,:,loopi) = final_T2STAR.*(final_Rho>0);%	
    ADC(:,:,loopi) = final_ADC.*(final_ADC>0);
    ECon = [];
    MassDen  = [];
%     disp(loopi)
%     subplot(231);imagesc(T1,[0,2]);colormap(jet);
%     subplot(232);imagesc(final_T2,[0,0.3]); colormap(jet);
%     subplot(233);imagesc(final_Rho,[0,1]); colormap(jet);
%     subplot(234);imagesc(final_T2STAR,[0,0.3]);colormap(jet);
%     subplot(235);imagesc(final_ADC);colormap(jet);
end
VObj.Rho = abs(Rho);VObj.T1 = abs(T1);VObj.T2 = abs(T2);VObj.T2Star = abs(T2STAR);VObj.ECon = abs(ECon);VObj.MassDen = abs(MassDen);VObj.WJG_ADC = abs(ADC);
out_obj = VObj;

save_file = ['/data3/wj/deep_model_wj_duffusion/',num2str(a)];
save(save_file,'VObj')
            
clear  'brain_mask'
