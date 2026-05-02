%created by Wang wei, ccb, li simin
%midified by WJG 2019.5.30  
%
function dB0=Mag_WW_LSM
%====================================
%====================================

inhomo=2000;%Hz  1500
GAMAR=267522120;
bandwidth=2*3.1415926*inhomo/GAMAR;
%% SM method
% p=[];
% p.Equation=[num2str(xishu_xy),'*X.*Y+',num2str(xishu_x2),'*X.^2+',num2str(xishu_y2),'*Y.^2+',num2str(xishu_x1),'*X+',num2str(xishu_y1),'*Y'];
% dB0t=MagSymbolic(p);
% dB0=bandwidth*dB0t./(max(max(dB0t)));
%% aX+bY+c
p.GradX=1.0*randi(10000)/10000-0.5;
p.GradY=1.0*randi(10000)/10000-0.5;
% p.GradX=1;
% p.GradY=1;
p.GradZ=0;
p.Scale=bandwidth;
dB0t=MagLinear(p);
dB0=dB0t;
p=[];
%% XY
scale=bandwidth;
xishu_rand = 1.0*randi(10000)/10000-0.5; 
p.Equation=[num2str(scale*xishu_rand),'*X.*Y'];
dB0t=MagSymbolic(p);
dB0=dB0+dB0t;
p=[];
%% X^2
xishu_rand = 1.0*randi(10000)/10000-0.5; 
p.Equation=[num2str(scale*xishu_rand),'*X.^2'];
dB0t=MagSymbolic(p);
dB0=dB0+dB0t;
p=[];
%% Y^2
xishu_rand = 1.0*randi(10000)/10000-0.5; 
p.Equation=[num2str(scale*xishu_rand),'*Y.^2'];
dB0t=MagSymbolic(p);
dB0=dB0+dB0t;
p=[];
%% X*Y^2
xishu_rand = 1.0*randi(10000)/10000-0.5; 
p.Equation=[num2str(scale*xishu_rand),'*X*Y.^2'];
dB0t=MagSymbolic(p);
dB0=dB0+dB0t;
p=[];
%% Y*X^2
xishu_rand = 1.0*randi(10000)/10000-0.5; 
p.Equation=[num2str(scale*xishu_rand),'*X.^2.*Y'];
dB0t=MagSymbolic(p);
dB0=dB0+dB0t;
p=[];
%% add more texture
[row,col] = size(dB0);
for loopi = 1:1
    dB0 = WJGshapeB0(dB0,row,col);
end
% figure();imshow(dB0*GAMAR/2/3.14,[]);colormap jet;colorbar

end
