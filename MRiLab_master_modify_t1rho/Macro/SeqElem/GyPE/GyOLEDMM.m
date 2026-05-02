
function [GAmp,GTime]=GyOLEDMM(p)

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
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase*2/8;
[GAmpG1,GTimeG1]=GyAreaTrapezoid2(p);
p=[];
%G2 the gradient between second and third pulse
p.tStart=VCtl.delta_TE*3/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KydK/VCtl.EPI_ShotNum*VCtl.ResPhase/8;
[GAmpG2,GTimeG2]=GyAreaTrapezoid2(p);
p=[];

%%%%%%%%%%%%%%%%%%%%%%sequence1
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
p.tStart=VCtl.T1D-10e-3;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=4*KyMax;
[WJGAmpSP1,WJGTimeSP1]=GyAreaTrapezoid2(p);
p=[];

% prephasing lob
p.tStart=VCtl.T1D+65e-3;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KyMax - (VVar.PhaseCount-1)*(KydK/VCtl.EPI_ShotNum);
[WJGAmp1,WJGTime1]=GyAreaTrapezoid2(p);
p=[];

% blip lobs
p.Area=KydK;
p.Duplicates=1;
p.DupSpacing=0;
WJGt2Middle = VCtl.T1D+120e-3;
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
%spoil
p.tStart=VCtl.T2D-10e-3;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=4*KyMax;
[WJGAmpSP2,WJGTimeSP2]=GyAreaTrapezoid2(p);
p=[];
% prephasing lob
p.tStart=VCtl.T2D+65e-3;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KyMax - (VVar.PhaseCount-1)*(KydK/VCtl.EPI_ShotNum);
[WJGAmp3,WJGTime3]=GyAreaTrapezoid2(p);
p=[];

% blip lobs
p.Area=KydK;
p.Duplicates=1;
p.DupSpacing=0;
WJGt2Middle = VCtl.T2D+120e-3;
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

GAmp=[GAmpG1*Gy2Sign,GAmpG2*Gy1Sign,GAmp1*Gy1Sign GAmp2*Gy2Sign,WJGAmpSP1*Gy2Sign,WJGAmp1*Gy1Sign,WJGAmp2*Gy2Sign,WJGAmp3*Gy1Sign,WJGAmp4*Gy2Sign];
GTime=[GTimeG1,GTimeG2,GTime1,GTime2,WJGTimeSP1,WJGTime1,WJGTime2,WJGTime3,WJGTime4];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
