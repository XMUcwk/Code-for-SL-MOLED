
function [GAmp,GTime]=ADCspenspiral(p)

global VCtl;
global VObj;

dt=1/VCtl.BandWidth;
tStart=p.tStart;
load('/data3/wangwei/mat1/RO_32k3ms_Ga_19_Smax_80_FOV_45_6996.mat');
GAmp=RO_Gsam;
num=length(GAmp);
% t=0:dt:dt*(num-1);
% t=t';
t=dt*num;
                   
[GAmp,GTime]=StdTrap(tStart+VCtl.TEAnchorTime-VCtl.MinUpdRate, ...
                     tStart+VCtl.TEAnchorTime+t+VCtl.MinUpdRate, ...
                     tStart+VCtl.TEAnchorTime,               ...
                     tStart+VCtl.TEAnchorTime+t,               ...
                     1,2,floor(t*VCtl.BandWidth),2);

                 
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
