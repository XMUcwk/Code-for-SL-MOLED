
function [GAmp,GTime]=Gyspenspiral70(p)

global VCtl;
global VObj;
global VVar;

dt=1/VCtl.BandWidth;
t1Start=p.t1Start;
load('PE_32k3ms_Ga_15_Smax_80_FOV_70_6996.mat');
GAmp=PE_Gsam;
GAmp=GAmp';
Gmax=32767;
Gpe=0.1534/1;
% Gpe=0.095;

% load('/data3/ww/重建/realgy.mat');
% GAmp=realgy';

num=length(GAmp);
t=0:dt:dt*(num-1);
GAmp=GAmp/Gmax*Gpe;
GTime = t1Start + VCtl.TEAnchorTime + t;
GTime = [GTime GTime(end) + VCtl.MinUpdRate];
GAmp = [GAmp 0];
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);
end
