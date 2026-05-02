
function [GAmp,GTime]=GxOLEDM(p)

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
p.Area=KxdK*VCtl.ResFreq/8*2*4;
[GAmpG1,GTimeG1]=GxAreaTrapezoid2(p);
p=[];
%G2  
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.delta_TE*3/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/8*2*4;	%1/2
[GAmpG2,GTimeG2]=GxAreaTrapezoid2(p);
p=[];
%G3  
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.delta_TE*5/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/8*2*4;
[GAmpG3,GTimeG3]=GxAreaTrapezoid2(p);
p=[];
%G4  
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.delta_TE*7/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/8*2*4;
[GAmpG4,GTimeG4]=GxAreaTrapezoid2(p);
p=[];
%G5  
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.delta_TE*9/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/8*2*4;
[GAmpG5,GTimeG5]=GxAreaTrapezoid2(p);
p=[];
%G6  
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.delta_TE*11/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/8*2*2;
[GAmpG6,GTimeG6]=GxAreaTrapezoid2(p);
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
GAmp=[GAmpG1*Gx1Sign,GAmpG2*Gx2Sign,GAmpG3*Gx1Sign,GAmpG4*Gx2Sign,GAmpG5*Gx1Sign,GAmpG6*Gx2Sign,GAmp1*Gx1Sign,GAmp2*Gx2Sign];
GTime=[GTimeG1,GTimeG2,GTimeG3,GTimeG4,GTimeG5,GTimeG6,GTime1 GTime2];
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
