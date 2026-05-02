function [T1_out,T2_out,Rho_out,new_mask] =  WJGshape1(T1,T2,Rho,mask,row,col,dirname,dirs,type)
%产生随机图形，并在图形内添加纹理
%在已经生成的T1,T2,Rho的基础上继续添加几何模板
%mask为几何模板
%dir为随机纹理的光学图像路径

radius_limit = row;
mini_size = 5;%最小尺寸
T1_out = T1;
T2_out = T2;
Rho_out = Rho;
switch type
    case 1    
        %生成圆
        mask1 = zeros(row,col);
        RADIUS = randi([mini_size,round(radius_limit/16)],1); 
        center = randi([20,row/2+round(radius_limit/4)],1,2); 
        temp_mask = WJGgenCircle(row,RADIUS,center);
        if(sum(temp_mask(:))>50)    %防止出现面积过小的图形
            mask1 = mask1+temp_mask;
        end
        new_mask = mask1.*abs(mask1-mask);%防止模板间重叠
        T1_out = Add_tex(T1,dirname,dirs,new_mask);  
        T2_out = Add_tex(T2,dirname,dirs,new_mask); 
        Rho_out = Add_tex(Rho,dirname,dirs,new_mask); 
        new_mask = abs(new_mask+mask)>0;  

    case 2
        %生成环
        mask1 = zeros(row,col);
        RADIUS1 = randi([mini_size,round(radius_limit/16)],1);
        RADIUS2 = randi([mini_size,round(radius_limit/16)],1);
        center = randi([20,row/2+round(radius_limit/4)],1,2); 
        temp_mask = WJGgenRing( row,max(RADIUS1,RADIUS2),min(RADIUS1,RADIUS2),center );
        if(sum(temp_mask(:))>50)    %防止出现面积过小的图形
            mask1 = mask1+temp_mask;
        end
        new_mask = mask1.*abs(mask1-mask);%防止模板间重叠
        T1_out = Add_tex(T1,dirname,dirs,new_mask);  
        T2_out = Add_tex(T2,dirname,dirs,new_mask); 
        Rho_out = Add_tex(Rho,dirname,dirs,new_mask); 
        new_mask = abs(new_mask+mask)>0; 
    case 3
        %生成正方形
        mask1 = zeros(row,col);
        shape = randi([1,round(radius_limit/4)],2,2);  %大小
        center = randi([20,row/2+round(radius_limit/8)],2,1); 
        center = [center,center];
        shape = shape+center;
        x = min([sort(shape(1,:));row,row]);    %控制范围
        y = min([sort(shape(2,:));col,col]);
        vx = [x(1),x(1),x(2),x(2),x(1)];
        vy = [y(1),y(2),y(2),y(1),y(1)];
        temp_mask = WJG_convex_S(row,vx,vy);
        if(sum(temp_mask(:))>50)    %防止出现面积过小的图形
            mask1 = mask1+temp_mask;
        end
        new_mask = mask1.*abs(mask1-mask);%防止模板间重叠
        T1_out = Add_tex(T1,dirname,dirs,new_mask);  
        T2_out = Add_tex(T2,dirname,dirs,new_mask); 
        Rho_out = Add_tex(Rho,dirname,dirs,new_mask); 
        new_mask = abs(new_mask+mask)>0;
    case 4 
%生成三角形
        mask1 = zeros(row,col);
        shape = randi([1,round(radius_limit/4)],2,3);
        center = randi([20,row/2+round(radius_limit/4)],2,1); 
        center = [center,center,center];
        shape = shape+center;
        x = min([sort(shape(1,:));row,row,row]);
        y = min([sort(shape(2,:));col,col,col]);
        vx = [x(1),x(2),x(3),x(1)];
        vy = [y(1),y(2),y(3),y(1)];
        temp_mask = WJG_convex_S(row,vx,vy);
        if(sum(temp_mask(:))>50)    %防止出现面积过小的图形
            mask1 = mask1+temp_mask;
        end
        new_mask = mask1.*abs(mask1-mask);%防止模板间重叠
        T1_out = Add_tex(T1,dirname,dirs,new_mask);  
        T2_out = Add_tex(T2,dirname,dirs,new_mask); 
        Rho_out = Add_tex(Rho,dirname,dirs,new_mask); 
        new_mask = abs(new_mask+mask)>0;
end
      
% imshow(mask1+mask2+mask3+mask4)

function out =  Add_tex(input,dirname,dirs,new_mask)
samples = length(dirs);
[row,col] = size(input);
frame_i = randi([1,samples],1); 
filename = [dirname,dirs(frame_i).name];
II = double(rgb2gray(imread(filename)))/255;%归一化
II = abs(imresize(II,[row,col],'nearest'));
out = new_mask.*II+input; 
