
function [GAmp,GTime]=Gzxspen(p)
global VCtl;
global VObj;
global VVar;

t1Start=p.t1Start;
t1End=p.t1End;
Gz1Sign=p.Gz1Sign;
BW  = VCtl.BW;
BWz=BW/2;

% prephasing lob
p.tStart=t1Start;
p.tEnd=t1End;
p.Duplicates=1;
p.DupSpacing=0;
p.sRamp=2;   % ramp steps 
p.GzAmp = BWz/(VObj.Gyro/(2*pi))/VCtl.SliceThick;
p.tRamp=max(VCtl.MinUpdRate,p.GzAmp/VCtl.MaxSlewRate);   % ramp time
[GAmp1,GTime1]=GzTrapezoid(p);

GAmp=[GAmp1*Gz1Sign];
GTime=[GTime1];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
