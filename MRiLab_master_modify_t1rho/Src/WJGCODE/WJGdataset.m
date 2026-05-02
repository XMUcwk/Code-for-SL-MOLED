%生成用于机器学习的训练样本
%几何图形
% by 吴健 XMU 
% 2018.4.4
clc;clear all;close all;
%随机生成若干几何图形
%样本的尺寸
row = 512;
col = row;
slice = 100;
num = 100;%掩膜数量
sigma = 1.1;%用于高斯滤波
gausFilter = fspecial('gaussian',[3 3],sigma);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%利用自然图像生成训练样本
%随机将几何图形的内部进行赋值
%读入自然图像
dirname = 'D:\Users\How\Desktop\angus\dataset\image\';
dirs=dir([dirname,'*.jpg']);
samples = length(dirs);
load('brain_mask');
mask_num = size(brain_mask,3);
for sam_loop = 1:10 %由于样本较多，将其分成几份
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%加载MRiLab模板
    load('BrainHighResolution')
    %修改参数
    VObj.XDim = row;
    VObj.YDim = col;
    VObj.ZDim = slice;
    %读入Rho
    Rho = zeros(row,col,slice);
    %读入T1
    T1 = zeros(row,col,slice);
    %读入T2
    T2 = zeros(row,col,slice);
    %读入T2Star
    T2Star = zeros(row,col,slice);
    %读入ECon
    ECon = zeros(row,col,slice,3);
    %读入MassDen
    MassDen =zeros(row,col,slice);
    max_slice = min([samples,mask_num,slice]);%防止溢出
    for loopi = 1:max_slice
        filename = [dirname,dirs((sam_loop-1)*max_slice+1).name];  %sam_loop表示提取的背景图片，要不断调整这个数字
        II1 = double(rgb2gray(imread(filename)))/255;%归一化
        II1 = abs(imresize(II1,[row,col]));    
        filename = [dirname,dirs((sam_loop-1)*max_slice+2).name];
        II2 = double(rgb2gray(imread(filename)))/255;%归一化
        II2 = abs(imresize(II2,[row,col])); 
        filename = [dirname,dirs((sam_loop-1)*max_slice+3).name];
        II3 = double(rgb2gray(imread(filename)))/255;%归一化
        II3 = abs(imresize(II3,[row,col])); 
        temp_brain_mask = brain_mask(:,:,mod(loopi,mask_num)+1);%循环取用模板   
        temp_brain_mask = imresize(temp_brain_mask,[row,col]);
        %mask+基础图像，图像打底
        temp_I1 = temp_brain_mask.*II1;
        temp_I2 = temp_brain_mask.*II2;
        temp_I3 = temp_brain_mask.*II3;
        %图形+mask
        %T1范围0~5s
        temp_mask = zeros(row,col);
        final_T1 = zeros(row,col);
        for loopj = 1:num
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_T1,temp_mask] =  WJGshape(final_T1,temp_mask,row,col,filename,1);%圆
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_T1,temp_mask] =  WJGshape(final_T1,temp_mask,row,col,filename,2);%环
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_T1,temp_mask] =  WJGshape(final_T1,temp_mask,row,col,filename,3);%正方形
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_T1,temp_mask] =  WJGshape(final_T1,temp_mask,row,col,filename,4);%三角形  
            new_mask = temp_brain_mask.*abs(temp_mask-temp_brain_mask);%%尽量填满
            if (sum(new_mask(:))<sum(temp_brain_mask(:))/8) 
                break;
            end
        end
        new_mask = temp_brain_mask.*abs(temp_brain_mask-temp_mask);%防止模板间重叠
        final_T1 = final_T1.*temp_brain_mask+temp_I1.*new_mask;
        final_T1=imfilter(final_T1,gausFilter,'replicate');
        final_T1 = final_T1*5;
        subplot(131);imshow(final_T1,[]); colormap(jet);title('T1');pause(0.001)

     %T2范围0~2.2s
        temp_mask = zeros(row,col);
        final_T2 = zeros(row,col);
        for loopj = 1:num
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_T2,temp_mask] =  WJGshape(final_T2,temp_mask,row,col,filename,1);%圆
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_T2,temp_mask] =  WJGshape(final_T2,temp_mask,row,col,filename,2);%环
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_T2,temp_mask] =  WJGshape(final_T2,temp_mask,row,col,filename,3);%正方形
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_T2,temp_mask] =  WJGshape(final_T2,temp_mask,row,col,filename,4);%三角形 
            new_mask = temp_brain_mask.*abs(temp_mask-temp_brain_mask);%%尽量填满
            if (sum(new_mask(:))<sum(temp_brain_mask(:))/8) 
                break;
            end
        end
        new_mask = temp_brain_mask.*abs(temp_brain_mask-temp_mask);%防止模板间重叠
        final_T2 = final_T2.*temp_brain_mask+temp_I2.*new_mask;
        final_T2=imfilter(final_T2,gausFilter,'replicate');
        final_T2 = final_T2*2.2;
        subplot(132);imshow(final_T2,[]); colormap(jet);title('T2');pause(0.001)

     %Rho范围0-1
        temp_mask = zeros(row,col);
        final_Rho = zeros(row,col);
        for loopj = 1:num
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_Rho,temp_mask] =  WJGshape(final_Rho,temp_mask,row,col,filename,1);%圆
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_Rho,temp_mask] =  WJGshape(final_Rho,temp_mask,row,col,filename,2);%环
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_Rho,temp_mask] =  WJGshape(final_Rho,temp_mask,row,col,filename,3);%正方形
            frame_i = randi([1,samples],1); 
            filename = [dirname,dirs(frame_i).name];
            [final_Rho,temp_mask] =  WJGshape(final_Rho,temp_mask,row,col,filename,4);%三角形
            new_mask = temp_brain_mask.*abs(temp_mask-temp_brain_mask);%%尽量填满
            if (sum(new_mask(:))<sum(temp_brain_mask(:))/8) 
                break;
            end
        end
        new_mask = temp_brain_mask.*abs(temp_brain_mask-temp_mask);%防止模板间重叠
        final_Rho = final_Rho.*temp_brain_mask+temp_I3.*new_mask;
        final_Rho=imfilter(final_Rho,gausFilter,'replicate');
        final_Rho = final_Rho*1;
        subplot(133);imshow(final_Rho,[]); colormap(jet);title('Rho');pause(0.001) 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改Rho%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Rho(:,:,loopi) = final_Rho;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改T1%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        T1(:,:,loopi) = final_T1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改T2%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        T2(:,:,loopi) = final_T2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%修改T2Star%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %设计T2Star
        WJG_T2Star = final_T2;    %所有T2设为
        T2Star(:,:,loopi) = WJG_T2Star;
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
    savename = ['WJG_DeeL',num2str((sam_loop-1)*max_slice+loopi)];
    save(savename,'VObj')
end
%