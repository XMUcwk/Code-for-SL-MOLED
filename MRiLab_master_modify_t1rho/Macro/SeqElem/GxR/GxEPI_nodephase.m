
function [GAmp,GTime]=GxEPI_nodephase(p)

global VCtl;
global VObj;
global VVar;

t1Start=p.t1Start;
t2Middle=p.t2Middle;
Gx1Sign=p.Gx1Sign;
Gx2Sign=p.Gx2Sign;

% frequency encoding
KxMax=(1/VCtl.RFreq)/2;

p=[];

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

GAmp=[GAmp2*Gx2Sign];
GTime=[GTime2];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
