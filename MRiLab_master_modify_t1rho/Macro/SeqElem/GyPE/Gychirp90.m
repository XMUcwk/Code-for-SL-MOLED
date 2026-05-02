
function [GAmp,GTime]=Gychirp90(p)

global VCtl;
global VObj;
global VVar;

t1Start=p.t1Start;
t1End=t1Start+VCtl.Texc;
BW  = VCtl.BW;
t2Middle=p.t2Middle;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;

% phase encoding
KyMax=(1/VCtl.RPhase)/2;
KydK=(2*KyMax)/VCtl.EPI_ETL;


% prephasing lob
p.tStart=t1Start;
p.tEnd=t1End;

p.Duplicates=1;
p.DupSpacing=0;
p.sRamp=2;   % ramp steps 
p.GyAmp = BW/(VObj.Gyro/(2*pi))/VCtl.FOVPhase;
p.tRamp=max(VCtl.MinUpdRate,p.GyAmp/VCtl.MaxSlewRate);   % ramp time
[GAmp1,GTime1]=GyTrapezoid(p);

%used for blip
% t_dur =  p.GyAmp*(t1End-t1Start)/VCtl.ResPhase;
Area =   p.GyAmp*(t1End-t1Start)/VCtl.ResPhase*(VObj.Gyro/(2*pi));

%%%%%%%%%%%%%%%%%
p=[];

% blip lobs
p.Area=Area;
p.Duplicates=1;
p.DupSpacing=0;
TimeOffset = (t2Middle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)-0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
GAmp2=[];
GTime2=[];
% p.GyAmp =VCtl.MaxGrad;
for i = 1: VCtl.EPI_ETL-1
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP;
    [GAmpt,GTimet]=GyAreaTrapezoid2(p);
    GAmp2=[GAmp2 GAmpt];
    GTime2=[GTime2 GTimet];
end

GAmp=[GAmp1*Gy1Sign  GAmp2*Gy2Sign];
GTime=[GTime1 GTime2];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
