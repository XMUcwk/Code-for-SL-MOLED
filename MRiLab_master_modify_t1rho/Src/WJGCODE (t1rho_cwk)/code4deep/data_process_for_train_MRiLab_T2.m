%process the result of MRiLab
% norm the data
%for deep learning
%
clc
clear 
close all
dirname='/data2/wj/T2/datagen/';
outputdir = '/data2/wj/T2/data4train1/';
fid_dir_all=dir([dirname,'sample4*']);       %list all directories
phase_num=128;
fre_num = 128;
expand_num = 256;
sigma=1e-2;
WJG_order=1;
for loopi = 1:length(fid_dir_all)
    fid_dir =[dirname,fid_dir_all(loopi).name,'/'];
    fid_file_all=dir([fid_dir,'DEEP*']);    %list all files
    for loopj = 1:length(fid_file_all)
        fid_file =[fid_dir,fid_file_all(loopj).name];
        load(fid_file)
        T2 = VSig.T2;
        T2 = abs(imresize(T2,[expand_num,expand_num],'nearest'));

        Sx = squeeze(VSig.Sx);
        Sy = squeeze(VSig.Sy);
        
        K1 = Sx+1i*Sy;
        K1 = reshape(K1,[fre_num,phase_num]);
        K1(:,2:2:end) = flipud(K1(:,2:2:end));

        expand_K1 = zeros(expand_num,expand_num);
        expand_K1((expand_num-phase_num)/2+1:(expand_num+phase_num)/2,(expand_num-fre_num)/2+1:(expand_num+fre_num)/2)=K1;
        I1=fftshift(ifft2(ifftshift(expand_K1)));     %(1,i f f)(2,f,i,i)
        I1 = I1/max(abs(I1(:)));
        I1 = flipud(imrotate(I1,90));
        both_img_noise=normrnd(0,sigma,expand_num,expand_num)+1.0i*normrnd(0,sigma,expand_num,expand_num);
        I1 = I1+both_img_noise;
        output(1,:,:) = real(I1);
        output(2,:,:) = imag(I1);
        output(3,:,:) = T2;
        figure(1);imshow(abs(I1),[]);colormap jet;colorbar
        figure(2);imshow(angle(I1),[]);colormap jet;colorbar
%         figure;imagesc(real(I1));colormap jet;colorbar
%         figure;imagesc(imag(I1));colormap jet;colorbar
        figure(3); imshow(abs(K),[]),colormap jet
%         figure(5);imshow(abs(ifftshift(fft2(fftshift(I1)))),[]);colormap jet;
%         filename=[outputdir,num2str(WJG_order),'.Charles'];
%         [fid,msg]=fopen(filename,'wb');
%         fwrite(fid,output,'single');
%         fclose(fid); 
%         WJG_order = WJG_order+1;
%         disp(WJG_order)
    end
    
%     imshow(abs(origin_2D_complex),[])
end




