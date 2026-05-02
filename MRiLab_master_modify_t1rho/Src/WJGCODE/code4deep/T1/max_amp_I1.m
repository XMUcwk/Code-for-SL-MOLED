%process the result of MRiLab
% scan the whole dataset to find the maximum amplitude of I
%check the data
%for deep learning
%Angus
function max_amp =  max_amp_I1(dirname)

max_amp=0;
fid_dir_all=dir([dirname,'sample*']);       %list all directories
phase_num=128;
fre_num = 128;
expand_num = 256;
WJG_order=1;
sig_length = phase_num*fre_num;
for loopi = 1:length(fid_dir_all)
    fid_dir =[dirname,fid_dir_all(loopi).name,'/'];
    fid_file_all=dir([fid_dir,'DEEP*']);    %list all files
    for loopj = 1:length(fid_file_all)
        fid_file =[fid_dir,fid_file_all(loopj).name];
        load(fid_file) 
        Sx = squeeze(VSig.Sx);
        Sy = squeeze(VSig.Sy);

        %% input
        fid=1;
        K1 = Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K1 = reshape(K1,fre_num,phase_num);
        K1(:,2:2:end) = flipud(K1(:,2:2:end));
        expand_K1 = zeros(expand_num,expand_num);
        expand_K1(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K1;
        I1=fftshift(ifft2(ifftshift(expand_K1)));     %(1,i f f)(2,f,i,i)
        max4norm = max(abs(I1(:)));
        if (max4norm>max_amp)
            max_amp = max4norm;
        end
        fid=3;
        K1 =  Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K1 = reshape(K1,fre_num,phase_num);
        K1(:,2:2:end) = flipud(K1(:,2:2:end));
        expand_K1 = zeros(expand_num,expand_num);
        expand_K1(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K1;
        I1=fftshift(ifft2(ifftshift(expand_K1)));     %(1,i f f)(2,f,i,i)
        max4norm = max(abs(I1(:)));
        if (max4norm>max_amp)
            max_amp = max4norm;
        end
        fid=5;
        K1 =  Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K1 = reshape(K1,fre_num,phase_num);
        K1(:,2:2:end) = flipud(K1(:,2:2:end));
        expand_K1 = zeros(expand_num,expand_num);
        expand_K1(round((expand_num-fre_num)/2+1):round((expand_num+fre_num)/2),round((expand_num-phase_num)/2+1):round((expand_num+phase_num)/2))=K1;
        I1=fftshift(ifft2(ifftshift(expand_K1)));     %(1,i f f)(2,f,i,i)
        max4norm = max(abs(I1(:)));
        if (max4norm>max_amp)
            max_amp = max4norm;
        end
                
        fid=6;
        K2 =  Sx((fid-1)*sig_length+1:fid*sig_length)+1i*Sy((fid-1)*sig_length+1:fid*sig_length);
        K2 = reshape(K2,fre_num,phase_num);
        K2(:,2:2:end) = flipud(K2(:,2:2:end));
        if sum(abs(K2(:,end)))==0 %avoid wrong data 
            disp ('wrong data2')
            fid_file
            break
        end
        
        WJG_order = WJG_order+1;
        disp(WJG_order)
    end
end




