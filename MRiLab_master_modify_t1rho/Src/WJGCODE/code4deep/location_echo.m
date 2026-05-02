%echo location statistic
%for deep learning
%Angus
clc
clear 
close all
dirname='/data3/wj/T2star_diffusion/datagen9/';
fid_dir_all=dir([dirname,'*1']);       %list all directories
phase_num=128;
fre_num = 128;
expand_num = 128;
sigma=1e-2;
WJG_order=1;
GAMMA = 2.675380303797068e+08/2/pi;
locations = zeros(expand_num,expand_num);
for loopi = 1:length(fid_dir_all)
    fid_dir =[dirname,fid_dir_all(loopi).name,'/'];
    fid_file_all=dir([fid_dir,'DEEP*']);    %list all files
    for loopj = 1:length(fid_file_all)
        fid_file =[fid_dir,fid_file_all(loopj).name];
        load(fid_file)
       %% input
        Sx = squeeze(VSig.Sx);
        Sy = squeeze(VSig.Sy);
        K1 = Sx(1:end/2)+1i*Sy(1:end/2);
        K1 = reshape(K1,fre_num,phase_num);
        K1(:,2:2:end) = flipud(K1(:,2:2:end));
        expand_K1 = zeros(expand_num,expand_num);
        expand_K1(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K1;
        temp_K = zeros(expand_num,expand_num);
        temp_K(1:end/2,1:end/2) = expand_K1(1:end/2,1:end/2);
        [loc1_row,loc_col] = find(abs(temp_K)==max(abs(temp_K(:))));
        locations(loc1_row,loc_col) =  locations(loc1_row,loc_col)+1;
        temp_K = zeros(expand_num,expand_num);
        temp_K(end/2+1:end,end/2+1:end) = expand_K1(end/2+1:end,end/2+1:end);
        [loc1_row,loc_col] = find(abs(temp_K)==max(abs(temp_K(:))));
        locations(loc1_row,loc_col) =  locations(loc1_row,loc_col)+1;
        
        
        WJG_order = WJG_order+1;
        disp(WJG_order)
    end
    
    imshow(abs((locations)),[]);colormap jet
    figure;imshow(abs(K1),[]);colormap jet
    figure;imshow(abs(temp_K),[]);colormap jet
end




