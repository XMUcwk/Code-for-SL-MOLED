%create model for MRiLab
% by Angus XMU 
% 2018.4.3
load('/media/angus/881003DD1003D0DC/MRiLab_master/Resources/VObj/BrainHighResolution')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change Rho%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rho
Rho = VObj.Rho;
%���Rho
[row,col,slice] = size(Rho);
slice = 2;
Rho = zeros(4*row,4*col,slice);
WJG_Rho = zeros([row,col]);
radius = round(min(row,col)/4);
for loopi = 1:row
    for loopj = 1:col
        if ( ((loopi-row/2)^2+(loopj-col/2)^2)<radius^2)
            WJG_Rho(loopi,loopj) = 1;
        end        
    end
end
%Rho
WJG_Rho = imresize(WJG_Rho,[4*row,4*col],'nearest');
for loopi = 1:slice
    Rho(:,:,loopi) = WJG_Rho;
end
VObj.Rho = Rho;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change T1%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%T1
T1 = zeros(4*row,4*col,slice);
%1
WJG_T1 = WJG_Rho*1;    %T1
%T1
for loopi = 1:slice
    T1(:,:,loopi) = WJG_T1;
end
WJG_T1 = imresize(WJG_T1,[4*row,4*col],'nearest');
VObj.T1 = T1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%T2%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%T2
T2 = zeros(4*row,4*col,slice);
%2
WJG_T2 = WJG_Rho*1;    %T2
%T2
for loopi = 1:slice
    T2(:,:,loopi) = WJG_T2;
end
VObj.T2 = T2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%T2Star%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%T2Star
T2Star =zeros(4*row,4*col,slice);
%���T2Star
WJG_T2Star = WJG_Rho*1;    %T2
%T2Star
for loopi = 1:slice
    T2Star(:,:,loopi) = WJG_T2Star;
end
VObj.T2Star = T2Star;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ECon%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%ECon
ECon = VObj.ECon;
%Con
WJG_ECon = 0;    %
%ECon
for loopi = 1:slice
    ECon(:,:,loopi) = WJG_ECon;
end
VObj.ECon = ECon;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%MassDen%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MassDen
MassDen = VObj.MassDen;
%Con
WJG_MassDen = 0;    %
%ECon
for loopi = 1:slice
    MassDen(:,:,loopi) = WJG_MassDen;
end
VObj.MassDen = MassDen;
VObj.XDim=4*col;
VObj.YDim=4*row;
VObj.ZDim=slice;
save WJG_onetube VObj



