
function [GAmp,GTime]=GxOLEDMM(p)

global VCtl;
global VObj;
global VVar;

t1Start=VCtl.refocus+4e-3;
t2Middle=p.t2Middle;
Gx1Sign=p.Gx1Sign;
Gx2Sign=p.Gx2Sign;

% frequency encoding
KxMax=(1/VCtl.RFreq)/2;
%G1  
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.delta_TE*1/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq*2*2/8;%
[GAmpG1,GTimeG1]=GxAreaTrapezoid2(p);
p=[];
%G2  
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.delta_TE*3/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq*2*1/8;	%
[GAmpG2,GTimeG2]=GxAreaTrapezoid2(p);
p=[];

% prephasing lob
p.tStart=t1Start;
p.Area=KxMax;
p.Duplicates=1;
p.DupSpacing=0;
[GAmp1,GTime1]=GxAreaTrapezoid2(p);
p=[];
%%%%%%%%%%%%%%%%%%%%%%sequence1
% readout lobs
p.GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*p.GxAmp*VCtl.RFreq);

TimeOffset = (t2Middle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)+0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
p.tRamp = VCtl.EPI_ESP/2 - tHalf;
p.sRamp = 2;
p.Duplicates=1;
p.DupSpacing=0;
GAmp2=[];
GTime2=[];
for i = 1: VCtl.EPI_ETL
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP + p.tRamp;
    p.tEnd = p.tStart + 2 * tHalf;
    [GAmpt,GTimet]=GxTrapezoid(p);
    GAmp2=[GAmp2 GAmpt*(-1)^(i-1)];
    GTime2=[GTime2 GTimet];
end
%%%%%%%%%%%%%%%%%%%%%%sequence2
% prephasing lob
p.tStart=VCtl.T1D+65e-3;
p.Area=KxMax;
p.Duplicates=1;
p.DupSpacing=0;
[WJGAmp1,WJGTime1]=GxAreaTrapezoid2(p);
p=[];

% readout lobs
%%%%%%%%%%%
p.GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*p.GxAmp*VCtl.RFreq);
WJGt2Middle = VCtl.T1D+120e-3;
TimeOffset = (WJGt2Middle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)+0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
p.tRamp = VCtl.EPI_ESP/2 - tHalf;
p.sRamp = 2;
p.Duplicates=1;
p.DupSpacing=0;
WJGAmp2=[];
WJGTime2=[];
for i = 1: VCtl.EPI_ETL
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP + p.tRamp;
    p.tEnd = p.tStart + 2 * tHalf;
    [WJGAmpt,WJGTimet]=GxTrapezoid(p);
    WJGAmp2=[WJGAmp2 WJGAmpt*(-1)^(i-1)];
    WJGTime2=[WJGTime2 WJGTimet];
end
%%%%%%%%%%%%%%%%%%%%%%sequence3
% prephasing lob
p.tStart=VCtl.T2D+65e-3;
p.Area=KxMax;
p.Duplicates=1;
p.DupSpacing=0;
[WJGAmp3,WJGTime3]=GxAreaTrapezoid2(p);
p=[];

% readout lobs
%%%%%%%%%%%
p.GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*p.GxAmp*VCtl.RFreq);
WJGt3Middle = VCtl.T2D+120e-3;
TimeOffset = (WJGt3Middle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)+0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
p.tRamp = VCtl.EPI_ESP/2 - tHalf;
p.sRamp = 2;
p.Duplicates=1;
p.DupSpacing=0;
WJGAmp4=[];
WJGTime4=[];
for i = 1: VCtl.EPI_ETL
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP + p.tRamp;
    p.tEnd = p.tStart + 2 * tHalf;
    [WJGAmpt,WJGTimet]=GxTrapezoid(p);
    WJGAmp4=[WJGAmp4 WJGAmpt*(-1)^(i-1)];
    WJGTime4=[WJGTime4 WJGTimet];
end
%%%%%%%%%%%%
GAmp=[GAmpG1*Gx2Sign,GAmpG2*Gx1Sign,GAmp1*Gx1Sign,GAmp2*Gx2Sign,WJGAmp1*Gx1Sign,WJGAmp2*Gx2Sign,WJGAmp3*Gx1Sign,WJGAmp4*Gx2Sign];
GTime=[GTimeG1,GTimeG2,GTime1,GTime2,WJGTime1,WJGTime2,WJGTime3,WJGTime4];
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
