clc
clear 
close all
dirname='/data2/wj/t2/datagen/';
fid_dir_all=dir([dirname,'sample*']);       %list all directories
phase_num=128;
fre_num = 128;
K_locate = zeros(fre_num,phase_num);
for loopi = 1:length(fid_dir_all)
    fid_dir =[dirname,fid_dir_all(loopi).name,'/'];
    fid_file_all=dir([fid_dir,'DEEP*']);    %list all files
    for loopj = 1:length(fid_file_all)
        fid_file =[fid_dir,fid_file_all(loopj).name];
        load(fid_file)
      
        Sx = squeeze(VSig.Sx);
        Sy = squeeze(VSig.Sy);
        
        K_space = Sx+1i*Sy;
        K_space = reshape(K_space,[fre_num,phase_num]);
        K_space(:,2:2:end) = flipud(K_space(:,2:2:end));

        I1=fftshift(ifft2(ifftshift(K_space)));     %(1,i f f)(2,f,i,i)
        K_1 = K_space(1:end/2,1:end/2);
        [loc_row,loc_col] = find(max(abs(K_1(:))) == abs(K_1));
        K_locate(loc_row,loc_col) = K_locate(loc_row,loc_col)+1;
        
    end
    
%     imshow(abs(K_locate),[])
end




