clc
clear
close all
% rename the files
dirname='/data3/wj/T2star/1002Hz_notexture/data4trainccbphantom/train/';
fid_dir_all=dir([dirname,'*.Charles']);       %list all directories
for loopi = 1:length(fid_dir_all)
    filename_before =[dirname,fid_dir_all(loopi).name];
    filename_after = [dirname,'notexture',fid_dir_all(loopi).name];
    movefile(filename_before,filename_after)
end