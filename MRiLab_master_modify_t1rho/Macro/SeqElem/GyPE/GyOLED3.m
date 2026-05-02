
function [GAmp,GTime]=GyOLED3(p)

global VCtl;
global VVar;

t1Start=(VCtl.TE+VCtl.delta_TE)/2+5e-3;
t2Middle=p.t2Middle;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;

% phase encoding
KyMax=(1/VCtl.RPhase)/2;
KydK=(2*KyMax)/VCtl.EPI_ETL;
%G1 the gradient between first and second pulse
p.tStart=VCtl.delta_TE/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/8*1;
[GAmpG1,GTimeG1]=GyAreaTrapezoid2(p);
p=[];
%G2 the gradient between second and third pulse
p.tStart=VCtl.delta_TE*3/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/8*1;
[GAmpG2,GTimeG2]=GyAreaTrapezoid2(p);
p=[];
%G3 the gradient between third and forth pulse
p.tStart=VCtl.delta_TE*5/4+VCtl.TE/4;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/8*1;
[GAmpG3,GTimeG3]=GyAreaTrapezoid2(p);
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

GAmp=[GAmpG1*Gy2Sign,GAmpG2*Gy2Sign,GAmpG3*Gy1Sign,GAmp1*Gy1Sign GAmp2*Gy2Sign];
GTime=[GTimeG1,GTimeG2,GTimeG3,GTime1 GTime2];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
