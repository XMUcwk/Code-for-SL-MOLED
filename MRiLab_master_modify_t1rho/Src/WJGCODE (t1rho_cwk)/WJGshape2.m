function [T1_out,T2_out,T2STAR_out,Rho_out,ADC_out,T1rho_out,new_mask] =  WJGshape2(T1,T2,T2STAR,Rho,ADC,T1rho,mask,row,col,dirname,dirs,type,ratio,range,T2max_temp,ADC_max_temp)
%generate geometry randomly, add texture
%add geometry mask on generated T1,T2,Rho
%mask 
%dir is the directory of optical images

radius_limit = row;
mini_size = 5;%the minimum size
min_range = min(range(1),range(3));
max_range = max(range(2),range(4));
switch type
    case 1    
        %circle
        mask1 = zeros(row,col);
        RADIUS = randi([mini_size,round(radius_limit/16)],1); 
        center = randi([min_range,max_range],2,1); 
        temp_mask = WJGgenCircle(row,RADIUS,center);
        if(sum(temp_mask(:))>50)    % prevent small circles
            mask1 = mask1+temp_mask;
        end
        new_mask = mask1.*abs(mask1-mask);% prevent mask overlapped
        [T1_out,T2_out,T2STAR_out,Rho_out,ADC_out,T1rho_out] =  Add_T2_tex(T1,T2,T2STAR,Rho,ADC,T1rho,dirname,dirs,new_mask,ratio,T2max_temp,ADC_max_temp);
        new_mask = abs(new_mask+mask)>0;  

    case 2
        %ring
        mask1 = zeros(row,col);
        RADIUS1 = randi([mini_size,round(radius_limit/16)],1);
        RADIUS2 = randi([mini_size,round(radius_limit/16)],1);
        center = randi([min_range,max_range],2,1); 
        temp_mask = WJGgenRing( row,max(RADIUS1,RADIUS2),min(RADIUS1,RADIUS2),center );
        if(sum(temp_mask(:))>50)    
            mask1 = mask1+temp_mask;
        end
        new_mask = mask1.*abs(mask1-mask);% 
        [T1_out,T2_out,T2STAR_out,Rho_out,ADC_out,T1rho_out] =  Add_T2_tex(T1,T2,T2STAR,Rho,ADC,T1rho,dirname,dirs,new_mask,ratio,T2max_temp,ADC_max_temp);
        new_mask = abs(new_mask+mask)>0; 
    case 3
        %square
        mask1 = zeros(row,col);
        shape = randi([1,round(radius_limit/4)],2,2);  %
        shape(1,:) = shape(1,:)-min(shape(1,:))+1;
        shape(2,:) = shape(2,:)-min(shape(2,:))+1;
        center = randi([min_range,max_range],2,1); 
        center = [center,center];
        shape = shape+center;
        x = min([sort(shape(1,:));row,row]);    % 
        y = min([sort(shape(2,:));col,col]);
        vx = [x(1),x(1),x(2),x(2),x(1)];
        vy = [y(1),y(2),y(2),y(1),y(1)];
        temp_mask = WJG_convex_S(row,vx,vy);
        if(sum(temp_mask(:))>50)    
            mask1 = mask1+temp_mask;
        end
        new_mask = mask1.*abs(mask1-mask);% 
        [T1_out,T2_out,T2STAR_out,Rho_out,ADC_out,T1rho_out] =  Add_T2_tex(T1,T2,T2STAR,Rho,ADC,T1rho,dirname,dirs,new_mask,ratio,T2max_temp,ADC_max_temp);
        new_mask = abs(new_mask+mask)>0;
    case 4 
%triangle
        mask1 = zeros(row,col);
        shape = randi([1,round(radius_limit/4)],2,3);
        shape(1,:) = shape(1,:)-min(shape(1,:))+1;
        shape(2,:) = shape(2,:)-min(shape(2,:))+1;
        center = randi([min_range,max_range],2,1); 
        center = [center,center,center];
        shape = shape+center;
        x = min([sort(shape(1,:));row,row,row]);
        y = min([sort(shape(2,:));col,col,col]);
        vx = [x(1),x(2),x(3),x(1)];
        vy = [y(1),y(2),y(3),y(1)];
        temp_mask = WJG_convex_S(row,vx,vy);
        if(sum(temp_mask(:))>50)    % 
            mask1 = mask1+temp_mask;
        end
        new_mask = mask1.*abs(mask1-mask); 
        [T1_out,T2_out,T2STAR_out,Rho_out,ADC_out,T1rho_out] =  Add_T2_tex(T1,T2,T2STAR,Rho,ADC,T1rho,dirname,dirs,new_mask,ratio,T2max_temp,ADC_max_temp);
        new_mask = abs(new_mask+mask)>0;
end
      
% imshow(mask1+mask2+mask3+mask4)




