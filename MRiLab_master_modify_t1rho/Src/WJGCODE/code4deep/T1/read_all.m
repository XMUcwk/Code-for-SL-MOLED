% clc
% clear
figure;
row=128;
col=128;
length=row*col;
ext_K = zeros(256,256);
for loopi = 1:2:5
    K = VSig.Sx((loopi-1)*length+1:loopi*length)+1i*VSig.Sy((loopi-1)*length+1:loopi*length);
    K = reshape(K,[row,col]);
    K(:,2:2:end) = flipud(K(:,2:2:end) );
    ext_K(65:65+127,65:65+127) = K;
    I = ifftshift(fft2(ifftshift(ext_K)));
    if (mod(loopi,2)==0)
        I = fliplr(I);
    end
%     subplot(2,3,loopi);
max_I = abs(I);

   figure(loopi); imshow(max_I,[]);colormap jet;axis off
end
% figure;imshow(VSig.T1,[0,3]);colormap jet