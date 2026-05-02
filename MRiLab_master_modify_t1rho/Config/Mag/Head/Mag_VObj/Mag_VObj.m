% WJG 2021.7.19
% read dB0 from VObj 
%
function dB0=Mag_VObj
%====================================
%====================================
GAMMA=267522120;
global VObj
 if (isfield(VObj,'B0'))
     dB0 = VObj.B0*2*3.14159/GAMMA*1.0;
 else
     dB0 = zeros(size(VObj.T2));
 end

% figure(9);imshow(dB0*GAMMA/2/3.14,[-100,100]);colormap jet;colorbar
end
