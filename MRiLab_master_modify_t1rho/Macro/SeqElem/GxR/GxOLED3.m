
function [GAmp,GTime]=GxOLED3(p)

global VCtl;
global VObj;
global VVar;

t1Start=(VCtl.TE+VCtl.delta_TE)/2+5e-3;
t2Middle=p.t2Middle;
Gx1Sign=p.Gx1Sign;
Gx2Sign=p.Gx2Sign;

% frequency encoding
KxMax=(1/VCtl.RFreq)/2;
%G1  
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.delta_TE/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/8*2*2;
[GAmpG1,GTimeG1]=GxAreaTrapezoid2(p);
p=[];
%G1  
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.delta_TE*3/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/8*2*2;
[GAmpG2,GTimeG2]=GxAreaTrapezoid2(p);
p=[];
%G2  
p.tStart=VCtl.delta_TE*5/4+VCtl.TE/4;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/8*2*2;
[GAmpG3,GTimeG3]=GxAreaTrapezoid2(p);
p=[];

% prephasing lob
p.tStart=t1Start;
p.Area=KxMax;
p.Duplicates=1;
p.DupSpacing=0;
[GAmp1,GTime1]=GxAreaTrapezoid2(p);
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
GAmp=[GAmpG1*Gx2Sign,GAmpG2*Gx2Sign,GAmpG3*Gx1Sign,GAmp1*Gx1Sign GAmp2*Gx2Sign];
GTime=[GTimeG1,GTimeG2,GTimeG3,GTime1 GTime2];
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
