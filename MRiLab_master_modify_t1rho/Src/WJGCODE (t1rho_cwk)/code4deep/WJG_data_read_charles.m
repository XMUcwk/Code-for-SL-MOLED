clc
clear 
close all
row =256;
col =256;

filename ='/data4/mlc/0419_without/train/data1010_withoutADC42.Charles';
fid = fopen(filename, 'r');
data_in = fread(fid,'single')';
step = length(data_in)/row/col;

for loopi = 1:step
    temp_input = data_in(loopi:step:end);
    M1= reshape(temp_input,[row,col]);
    subplot(3,4,loopi);
    imshow(M1,[]);colormap jet
end



