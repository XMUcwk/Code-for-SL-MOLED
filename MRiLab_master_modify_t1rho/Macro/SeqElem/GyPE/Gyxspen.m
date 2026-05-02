
function [GAmp,GTime]=Gyxspen(p)

global VCtl;
global VObj;
global VVar;

t1Start=p.t1Start;
t1End=t1Start+VCtl.Texc;
t2Start=p.t2Start;
t2End=t2Start+VCtl.Texc;
BW  = VCtl.BW;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;
BWy=BW/2;


p=[];
% first
p.tStart=t1Start;
p.tEnd=t1End;
p.Duplicates=1;
p.DupSpacing=0;
p.sRamp=2;   % ramp steps 
p.GyAmp = BWy/(VObj.Gyro/(2*pi))/VCtl.FOVPhase;
p.tRamp=max(VCtl.MinUpdRate,p.GyAmp/VCtl.MaxSlewRate);   % ramp time
[GAmp1,GTime1]=GyTrapezoid(p);
p=[];
GAmp2=[];
GTime2=[];
% second
p.tStart=t2Start;
p.tEnd=t2End;
p.Duplicates=1;
p.DupSpacing=0;
p.sRamp=2;   % ramp steps 
p.GyAmp = BWy/(VObj.Gyro/(2*pi))/VCtl.FOVPhase;
p.tRamp=max(VCtl.MinUpdRate,p.GyAmp/VCtl.MaxSlewRate);   % ramp time
[GAmp2,GTime2]=GyTrapezoid(p);

GAmp=[GAmp1*Gy1Sign GAmp2*Gy2Sign];
GTime=[GTime1 GTime2];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
