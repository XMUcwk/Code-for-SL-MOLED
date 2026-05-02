function [B0_out] =  WJGshapeB0(B0,row,col)
%generate random B0
global VObj 
rand_x = randi([row/10,row-row/10],1);
rand_y = randi([col/10,col-col/10],1);
p.PosX = (rand_x-VObj.XDim/2)*VObj.XDimRes;
p.PosY = (rand_y-VObj.YDim/2)*VObj.YDimRes;
p.DeltaX=VObj.XDimRes*randi([50,100],1);
p.DeltaY=VObj.XDimRes*randi([50,100],1);
p.DeltaZ = 1000;
p.PosZ=0;
p.Scale=5e-6*(1.0*randi(10000)/10000-0.5);
% disp(p.DeltaX);
% disp(p.DeltaY);
% disp(p.PosX);
% disp(p.PosY);
dB0t=MagGaussian(p);
B0_out = B0+dB0t;
      





