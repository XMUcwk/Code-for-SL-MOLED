clc
clear all
close all
%用于生成训练用的大脑的掩膜
load('BrainModel');
brain_mask = Anatomy(:,:,20:end);%前20层质量不好，不用
mask_num = size(brain_mask,3);
row = 256;
final_mask = zeros(row,row,mask_num);
for loopi = 1:mask_num
    temp_brain_mask = brain_mask(:,:,loopi);%循环取用模板
    temp_brain_mask = imresize(temp_brain_mask,[row-20,row-20]);
    temp_brain_mask = padarray(temp_brain_mask,[10,10]);
    level = graythresh(temp_brain_mask);
    temp_brain_mask = im2bw(temp_brain_mask,level);
    se1=strel('disk',3);%这里是创建一个半径为5的平坦型圆盘结构元素
    temp_brain_mask=imclose(temp_brain_mask,se1);%先开后闭运算;
    imshow(temp_brain_mask,[])
    final_mask(:,:,loopi) = temp_brain_mask;
end
