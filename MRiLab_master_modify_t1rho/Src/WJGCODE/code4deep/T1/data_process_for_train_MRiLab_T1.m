%process the result of MRiLab
% norm the data
%for deep learning
%Angus
clc
clear 
close all
dirname='/data3/wj/T1/data4train/datagen4/';
outputdir = [dirname, 'data4train2/'];
fid_dir_all=dir([dirname,'sample*']);       %list all directories
phase_num=128;
fre_num = 128;
sig_length = phase_num*fre_num;
expand_num = 256;
sigma=1e-2;
WJG_order=1;
GAMMA = 2.675380303797068e+08/2/pi;
% max_amp = 3.3;%max_amp_I1(dirname);
for loopi = 1:length(fid_dir_all)
    fid_dir =[dirname,fid_dir_all(loopi).name,'/'];
    fid_file_all=dir([fid_dir,'DEEP*']);    %list all files
    for loopj = 1:length(fid_file_all)
        fid_file =[fid_dir,fid_file_all(loopj).name];
        load(fid_file)
        %% T2
        T2 = VSig.T2;
        T2 = abs(imresize(T2,[expand_num,expand_num],'nearest'));
        T2 = imrotate(T2,180);
        %% T2star
%         T2STAR = VSig.T2STAR;
%         T2STAR = abs(imresize(T2STAR,[expand_num,expand_num],'nearest'));
%         T2STAR = imrotate(T2STAR,180);
        %% T1
        T1 = VSig.T1;
        T1 = abs(imresize(T1,[expand_num,expand_num],'nearest'));
        T1 = imrotate(T1,180);
        %% B0
%         B0 = VSig.B0*GAMMA;
%         B0 = imresize(B0,[expand_num,expand_num],'nearest');
%         B0 = imrotate(B0,180);
        %% B1
        B1 = VSig.B1;
        B1 = abs(imresize(B1,[expand_num,expand_num],'nearest'));
        B1 = imrotate(B1,180);
        %% M0
        M0 = VSig.Rho;
        M0 = abs(imresize(M0,[expand_num,expand_num],'nearest'));
        M0 = imrotate(M0,180);
        mask = M0>0;
        Sx = squeeze(VSig.Sx);
        Sy = squeeze(VSig.Sy);

        %% input fid1
        fid=1;
        K1 = Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K1 = reshape(K1,fre_num,phase_num);
        K1(:,2:2:end) = flipud(K1(:,2:2:end));
        expand_K1 = zeros(expand_num,expand_num);
        expand_K1(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K1;
        I1=fftshift(ifft2(ifftshift(expand_K1)));     %(1,i f f)(2,f,i,i)
        max_amp = max(abs(I1(:)));
        I1 = I1/max_amp;
        both_img_noise=normrnd(0,sigma,expand_num,expand_num)+1.0i*normrnd(0,sigma,expand_num,expand_num);
        I1 = I1+both_img_noise;
          %% input fid2
        fid=2;
        K2 = Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K2 = reshape(K2,fre_num,phase_num);
        K2(:,2:2:end) = flipud(K2(:,2:2:end));
        expand_K2 = zeros(expand_num,expand_num);
        expand_K2(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K2;
        I2=fftshift(ifft2(ifftshift(expand_K2)));     %(1,i f f)(2,f,i,i)
        I2 = fliplr(I2/max_amp);
        both_img_noise=normrnd(0,sigma,expand_num,expand_num)+1.0i*normrnd(0,sigma,expand_num,expand_num);
        I2 = I2+both_img_noise;

        %% fid3
        fid=3;
        K3 = Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K3 = reshape(K3,fre_num,phase_num);
        K3(:,2:2:end) = flipud(K3(:,2:2:end));
        expand_K3 = zeros(expand_num,expand_num);
        expand_K3(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K3;
        I3=fftshift(ifft2(ifftshift(expand_K3)));     %(1,i f f)(2,f,i,i)
        I3 = I3/max_amp;
        both_img_noise=normrnd(0,sigma,expand_num,expand_num)+1.0i*normrnd(0,sigma,expand_num,expand_num);
        I3 = I3+both_img_noise;  
        %% fid4 
        fid=4;
        K4 = Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K4 = reshape(K4,fre_num,phase_num);
        K4(:,2:2:end) = flipud(K4(:,2:2:end));
        expand_K4 = zeros(expand_num,expand_num);
        expand_K4(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K4;
        I4=fftshift(ifft2(ifftshift(expand_K4)));     %(1,i f f)(2,f,i,i)
        I4 = fliplr(I4/max_amp);
        both_img_noise=normrnd(0,sigma,expand_num,expand_num)+1.0i*normrnd(0,sigma,expand_num,expand_num);
        I4 = I4+both_img_noise;  
       %% fid5
        fid=5;
        K5 = Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K5 = reshape(K5,fre_num,phase_num);
        K5(:,2:2:end) = flipud(K5(:,2:2:end));
        expand_K5 = zeros(expand_num,expand_num);
        expand_K5(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K5;
        I5=fftshift(ifft2(ifftshift(expand_K5)));     %(1,i f f)(2,f,i,i)
        I5 = I5/max_amp;
        both_img_noise=normrnd(0,sigma,expand_num,expand_num)+1.0i*normrnd(0,sigma,expand_num,expand_num);
        I5 = I5+both_img_noise;  
        %% fid6
        fid=6;
        K6 = Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K6 = reshape(K6,fre_num,phase_num);
        K6(:,2:2:end) = flipud(K6(:,2:2:end));
        expand_K6 = zeros(expand_num,expand_num);
        expand_K6(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K6;
        I6=fftshift(ifft2(ifftshift(expand_K6)));     %(1,i f f)(2,f,i,i)
        I6 = fliplr(I6/max_amp);
        both_img_noise=normrnd(0,sigma,expand_num,expand_num)+1.0i*normrnd(0,sigma,expand_num,expand_num);
        I6 = I6+both_img_noise;      
        
        
%         subplot(231);imshow((abs(I1)),[]);colormap jet
%         subplot(232);imshow((abs(I2)),[]);colormap jet
%         subplot(233);imshow((abs(I3)),[]);colormap jet
%         subplot(234);imshow((abs(I4)),[]);colormap jet
%         subplot(235);imshow((abs(I5)),[]);colormap jet
%         subplot(236);imshow((abs(I6)),[]);colormap jet
  %%%%%
%         output(1,:,:) = real(I1);
%         output(2,:,:) = imag(I1);
%         output(3,:,:) = real(I3);
%         output(4,:,:) = imag(I3);
%         output(5,:,:) = real(I5);
%         output(6,:,:) = imag(I5);
%         output(7,:,:) = T1;
%%%%
        output(1,:,:) = real(I1);
        output(2,:,:) = imag(I1);
        output(3,:,:) = real(I2);
        output(4,:,:) = imag(I2);
        output(5,:,:) = real(I3);
        output(6,:,:) = imag(I3);
        output(7,:,:) = real(I4);
        output(8,:,:) = imag(I4);
        output(9,:,:) = real(I5);
        output(10,:,:) = imag(I5);
        output(11,:,:) = real(I6);
        output(12,:,:) = imag(I6);
        output(13,:,:) = T1;
%%%%%%%%
%         output(6,:,:) = T2STAR*3;
%         output(7,:,:) = B0.*mask/50;
%         output(8,:,:) = M0;
%         output(9,:,:) = B1.*mask;
        

        filename=[outputdir,num2str(WJG_order),'.Charles'];
        [fid,msg]=fopen(filename,'wb');
        fwrite(fid,output,'single');
        fclose(fid); 
        WJG_order = WJG_order+1;
        disp(WJG_order)
    end
    
end




