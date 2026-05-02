
function [GAmp,GTime]=GyOLEDM(p)

global VCtl;
global VVar;

t1Start=VCtl.refocus+4e-3;
t2Middle=p.t2Middle;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;

% phase encoding
KyMax=(1/VCtl.RPhase)/2;
KydK=(2*KyMax)/VCtl.EPI_ETL;
%G1 the gradient between first and second pulse
p.tStart=VCtl.delta_TE*1/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/6;
[GAmpG1,GTimeG1]=GyAreaTrapezoid2(p);
p=[];
%G2 the gradient between second and third pulse
p.tStart=VCtl.delta_TE*3/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/6;
[GAmpG2,GTimeG2]=GyAreaTrapezoid2(p);
p=[];
%G3 the gradient between third and forth pulse
p.tStart=VCtl.delta_TE*5/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/6;
[GAmpG3,GTimeG3]=GyAreaTrapezoid2(p);
p=[];
%G4 the gradient between forth and firth pulse
p.tStart=VCtl.delta_TE*7/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/6;
[GAmpG4,GTimeG4]=GyAreaTrapezoid2(p);
p=[];
%G5 the gradient between firth and sixth pulse
p.tStart=VCtl.delta_TE*9/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/6;
[GAmpG5,GTimeG5]=GyAreaTrapezoid2(p);
p=[];
%G6 the gradient between  sixth pulse and beta
p.tStart=VCtl.delta_TE*11/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase*5/12;
[GAmpG6,GTimeG6]=GyAreaTrapezoid2(p);
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

GAmp=[GAmpG1*Gy1Sign,GAmpG2*Gy1Sign,GAmpG3*Gy1Sign,GAmpG4*Gy1Sign,GAmpG5*Gy1Sign,GAmpG6*Gy2Sign,GAmp1*Gy1Sign GAmp2*Gy2Sign];
GTime=[GTimeG1,GTimeG2,GTimeG3,GTimeG4,GTimeG5,GTimeG6,GTime1 GTime2];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
