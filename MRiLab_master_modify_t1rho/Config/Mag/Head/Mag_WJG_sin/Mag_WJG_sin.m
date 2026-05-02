%created by WJG 2019.8.27  
%
function dB0=Mag_WJG_sin
%====================================
%====================================

inhomo=1500;%Hz
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

%% XY
p.Equation=[num2str(1e-06),'*sin(1000*X)'];
dB0t=MagSymbolic(p);
dB0=dB0t;

end
