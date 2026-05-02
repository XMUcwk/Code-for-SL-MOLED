function [T1_out,T2_out,T2STAR_out,Rho_out] =  Add_T2_tex_brain(T1,T2,T2STAR,Rho,dirname,dirs,new_mask,ratio)
% T1=5s��T2=2s
T1max=5000;
T2max=2000;
sigma = 4;    %gaussian filter
gausFilter = fspecial('gaussian',[8 8],sigma);

%tissuse parameters
%        T1  T2 T2*[ms]  M0 CS[rad/sec]      Label
tissue=[2569 329  158   1.00   0         ;  % 1 = CSF
        833  83   69   0.86   0         ;  % 2 = GM
        833  83   69   0.86   0         ;  % 2 = GM
        833  83   69   0.8   0         ;  % 2 = GM
        833  83   69   0.7   0         ;  % 2 = GM
        500  70   61   0.7   0         ;  % 3 = WM
        500  70   61   0.77   0         ;  % 3 = WM
        500  70   61   0.6   0         ;  % 3 = WM
        500  70   61   0.77   0         ;  % 3 = WM
%         350  70   58   1.00 220*2*pi    ;  % 4 = Fat (CS @ 1.5 Tesla)
        350  70   58   1.00 220*2*pi    ;  % 4 = Fat (CS @ 1.5 Tesla)
%         900  47   30   1.00   0         ;  % 5 = Muscle / Skin
        900  47   30   1.00   0         ;  % 5 = Muscle / Skin
%         0   0    0   0.00   0         ;  % 7 = Skull
        833  83   69   0.86   0         ;  % 8 = Glial Matter
        833  83   69   0.86   0         ;  % 8 = Glial Matter
        833  83   69   0.8   0         ;  % 8 = Glial Matter
        833  83   69   0.8   0         ;  % 8 = Glial Matter
        500  70   61   0.77   0         ;% 9 = Meat
        500  70   61   0.6   0         ;% 9 = Meat
        500  70   61   0.6   0         ];% 9 = Meat
samples = length(dirs);
[row,col] = size(T1);
pos = randi([1,length(tissue)],1); 
T1_T2 = tissue(pos,:);
sig=0.1;


% T1_temp = normrnd(T1_T2(1),T1_T2(1)*sig);
% T2_temp = normrnd(T1_T2(2),T1_T2(2)*sig);
% Rho_temp = normrnd(T1_T2(4),T1_T2(4)*sig);
T1_temp = T1_T2(1)-sig*T1_T2(1)+rand()*2*sig*T1_T2(1);
T2_temp = T1_T2(2)-sig*T1_T2(2)+rand()*2*sig*T1_T2(2);
T2STARmin = 25;
T2STARmax = T2_temp;
T2STAR_temp = unifrnd(T2STARmin,T2STARmax);
Rho_temp = unifrnd(0.1,1,1);

%% T1
T1_base = double(ones(row,col)*T1_temp);% 
T1_base = abs(imresize(T1_base,[row,col],'nearest'));
T1_base = abs(imfilter(T1_base,gausFilter,'replicate'));
frame_i = randi([1,samples],1); 
filename = [dirname,dirs(frame_i).name];
II1 = double(rgb2gray(imread(filename)))/255*T1_T2(1);%  !!!! maybe wrong here
II1 = abs(imresize(II1,[row,col],'nearest'));
II1 = abs(imfilter(II1,gausFilter,'replicate'));
T1_out = new_mask.*II1*ratio+(new_mask.*T1_base*(1-ratio))+T1;  

%% T2
T2_base = double(ones(row,col)*T2_temp);% 
T2_base = abs(imresize(T2_base,[row,col],'nearest'));
T2_base = abs(imfilter(T2_base,gausFilter,'replicate'));
frame_i = randi([1,samples],1); 
filename = [dirname,dirs(frame_i).name];
II2 = double(rgb2gray(imread(filename)))/255*T1_T2(2);% 
II2 = abs(imresize(II2,[row,col],'nearest'));
II2 = abs(imfilter(II2,gausFilter,'replicate'));
T2_out = new_mask.*II2*ratio+(new_mask.*T2_base*(1-ratio))+T2; 
%% T2STAR
T2STAR_base = double(ones(row,col)*T2STAR_temp);% 
T2STAR_base = abs(imresize(T2STAR_base,[row,col],'nearest'));
T2STAR_base = abs(imfilter(T2STAR_base,gausFilter,'replicate'));
frame_i = randi([1,samples],1); 
filename = [dirname,dirs(frame_i).name];
II2 = double(rgb2gray(imread(filename)))/255*T1_T2(2);% 
II2 = abs(imresize(II2,[row,col],'nearest'));
II2 = abs(imfilter(II2,gausFilter,'replicate'));
T2STAR_out = new_mask.*II2*ratio+(new_mask.*T2STAR_base*(1-ratio))+T2STAR; 
%% Rho
Rho_base = double(ones(row,col)*Rho_temp);% 
Rho_base = abs(imresize(Rho_base,[row,col],'nearest'));
Rho_base = abs(imfilter(Rho_base,gausFilter,'replicate'));
frame_i = randi([1,samples],1); 
filename = [dirname,dirs(frame_i).name];
II3 = double(rgb2gray(imread(filename)))/255*T1_T2(4);% 
II3 = abs(imresize(II3,[row,col],'nearest'));
II3 = abs(imfilter(II3,gausFilter,'replicate'));
ratio = ratio/2;
Rho_out = new_mask.*II3*ratio+(new_mask.*Rho_base*(1-ratio))+Rho; 