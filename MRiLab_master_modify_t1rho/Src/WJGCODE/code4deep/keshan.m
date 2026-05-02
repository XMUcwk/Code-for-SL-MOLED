%process the result of MRiLab
% norm the data
%for deep learning
%Angus

phase_num=128;
fre_num = 128;
expand_num = 256;
sigma=1e-2;
WJG_order=1;
GAMMA = 2.675380303797068e+08/2/pi;
Sx = squeeze(VSig.Sx);
Sy = squeeze(VSig.Sy);
%% input
K1 = Sx(1:end/2)+1i*Sy(1:end/2);
K1 = reshape(K1,fre_num,phase_num);
K1(:,2:2:end) = flipud(K1(:,2:2:end));
expand_K1 = zeros(expand_num,expand_num);
expand_K1(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K1;
I1=fftshift(ifft2(ifftshift(expand_K1)));     %(1,i f f)(2,f,i,i)
max4norm = max(abs(I1(:)));
I1 = I1/max4norm;

imshow(abs(K1),[]);colormap jet

K2 = Sx(end/2+1:end)+1i*Sy(end/2+1:end);
K2 = reshape(K2,fre_num,phase_num);
K2(:,2:2:end) = flipud(K2(:,2:2:end));
imshow(abs(K2),[]);colormap jet
expand_K2 = zeros(expand_num,expand_num);
expand_K2(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K2;
I2=fftshift(ifft2(ifftshift(expand_K2)));     %(1,i f f)(2,f,i,i)
imshow(abs(K2),[]);colormap jet




