
function [GAmp,GTime]=GyLLOLED(p)

global VCtl;
global VVar;

t1Start=VCtl.CV3+VCtl.CV5+VCtl.CV6+10e-3;
t2Middle=p.t2Middle;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;

% phase encoding
KyMax=(1/VCtl.RPhase)/2;
KydK=(2*KyMax)/VCtl.EPI_ETL;
%G1  
p.tStart=VCtl.CV3+VCtl.CV5+VCtl.CV6/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/8*2;
[GAmpG1,GTimeG1]=GyAreaTrapezoid2(p);
p=[];
%G2 
p.tStart=VCtl.CV3+VCtl.CV5+VCtl.CV6+5e-3;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/8;
[GAmpG2,GTimeG2]=GyAreaTrapezoid2(p);
p=[];


% prephasing lob
p.tStart=t1Start;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KyMax - (VVar.PhaseCount-1)*(KydK/VCtl.EPI_ShotNum);
[GAmp1,GTime1]=GyAreaTrapezoid2(p);
p=[];

% blip lobs
p.Area=KydK;
p.Duplicates=1;
p.DupSpacing=0;
TimeOffset = (t2Middle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)-0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
GAmp2=[];
GTime2=[];
for i = 1: VCtl.EPI_ETL-1
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP;
    [GAmpt,GTimet]=GyAreaTrapezoid2(p);
    GAmp2=[GAmp2 GAmpt];
    GTime2=[GTime2 GTimet];
end

GAmp=[GAmpG1*Gy2Sign,GAmpG2*Gy1Sign,GAmp1*Gy1Sign GAmp2*Gy2Sign];
GTime=[GTimeG1,GTimeG2,GTime1 GTime2];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

Duplicates=2;
DupSpacing = VCtl.CV4;
% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    GAmp=repmat(GAmp,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[length(GTime) 1]);
    GTime=repmat(GTime,[1 Duplicates]) + (TimeOffset(:))';
end

end
