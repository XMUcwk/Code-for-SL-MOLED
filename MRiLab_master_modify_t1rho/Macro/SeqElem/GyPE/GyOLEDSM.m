
function [GAmp,GTime]=GyOLEDSM(p)

global VCtl;
global VVar;

t1Start=VCtl.TE/2+VCtl.delta_TE/4+5e-3;
t2Middle=p.t2Middle;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;

% phase encoding
KyMax=(1/VCtl.RPhase)/2;
KydK=(2*KyMax)/VCtl.EPI_ETL;
%G1  
p.tStart=VCtl.delta_TE/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/8*4;
[GAmpG1,GTimeG1]=GyAreaTrapezoid2(p);
p=[];
%G2 
p.tStart=VCtl.delta_TE*3/4+VCtl.TE/4;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/8*2;
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
%%%%%%%%%%%%%%%%%%%%%%sequence2
%spoil
p.tStart=VCtl.Refocus-1e-3;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=4*KyMax;
[WJGAmpSP1,WJGTimeSP1]=GyAreaTrapezoid2(p);
p=[];

% blip lobs
p.Area=KydK;
p.Duplicates=1;
p.DupSpacing=0;
WJGt2Middle = 2*VCtl.Refocus-VCtl.TE;
TimeOffset = (WJGt2Middle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)-0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
WJGAmp2=[];
WJGTime2=[];
for i = 1: VCtl.EPI_ETL-1
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP;
    [WJGAmpt,WJGTimet]=GyAreaTrapezoid2(p);
    WJGAmp2=[WJGAmp2 WJGAmpt];
    WJGTime2=[WJGTime2 WJGTimet];
end
%%%%%%%%%%%%%%%%%%%%%%sequence3
% prephasing lob
%p.tStart=(VCtl.T1TE+VCtl.T1Exc)/2+5e-3;
p.tStart = VCtl.T1Exc+5e-3;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KyMax - (VVar.PhaseCount-1)*(KydK/VCtl.EPI_ShotNum);
[WJGAmp3,WJGTime3]=GyAreaTrapezoid2(p);
p=[];

% blip lobs
p.Area=KydK;
p.Duplicates=1;
p.DupSpacing=0;
WJGt2Middle = VCtl.T1TE;
TimeOffset = (WJGt2Middle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)-0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
WJGAmp4=[];
WJGTime4=[];
for i = 1: VCtl.EPI_ETL-1
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP;
    [WJGAmpt,WJGTimet]=GyAreaTrapezoid2(p);
    WJGAmp4=[WJGAmp4 WJGAmpt];
    WJGTime4=[WJGTime4 WJGTimet];
end
%%%%%%%%%%%%%%%%%
GAmp=[GAmpG1*Gy2Sign,GAmpG2*Gy1Sign,GAmp1*Gy1Sign GAmp2*Gy2Sign WJGAmp2*Gy1Sign WJGAmp3*Gy1Sign WJGAmp4*Gy2Sign];
GTime=[GTimeG1,GTimeG2,GTime1 GTime2 WJGTime2 WJGTime3 WJGTime4];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
