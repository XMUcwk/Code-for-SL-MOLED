% clc
% clear 
% close all
figure;
imagesc(output_image(:,:,1),[0,0.3]);colormap jet;colorbar
figure;
% imagesc(output_image(:,:,2),[0,0.2]);colormap jet;colorbar
figure;
imagesc([test_label(:,:,1),test_label(:,:,2)]);
figure;
imagesc([input_image]);
colormap jet
set(gca, 'position',[0,0,1,1]);
