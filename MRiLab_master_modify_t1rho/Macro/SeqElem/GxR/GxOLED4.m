
function [GAmp,GTime]=GxOLED4(p)

global VCtl;
global VObj;
global VVar;

t1Start=VCtl.TEAnchorTime+VCtl.TE/2+VCtl.delta_TE+2.5e-3;
t2Middle=p.t2Middle;
Gx1Sign=p.Gx1Sign;
Gx2Sign=p.Gx2Sign;

% frequency encoding
KxMax=(1/VCtl.RFreq)/2;
%G1  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%add the random to the pulse    -2%~+2%
WJG_rang =randi([-100,100],1)*3/100/100;
KxMax = (1+WJG_rang)*KxMax;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.CV4+VCtl.delta_TE/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/6*2*2;
[GAmpG1,GTimeG1]=GxAreaTrapezoid2(p);
p=[];
%G2  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%add the random to the pulse    -2%~+2%
WJG_rang =randi([-100,100],1)*3/100/100;
KxMax = (1+WJG_rang)*KxMax;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KxdK = KxMax/VCtl.ResFreq;
p.tStart=VCtl.CV4+VCtl.delta_TE*2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/6*2*2;
[GAmpG2,GTimeG2]=GxAreaTrapezoid2(p);
p=[];
%G3  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%add the random to the pulse    -2%~+2%
WJG_rang =randi([-100,100],1)*3/100/100;
KxMax = (1+WJG_rang)*KxMax;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.tStart=VCtl.CV4+VCtl.delta_TE*7/2;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/6*2*2;
[GAmpG3,GTimeG3]=GxAreaTrapezoid2(p);
p=[];
%G4  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%add the random to the pulse    -2%~+2%
WJG_rang =randi([-100,100],1)*3/100/100;
KxMax = (1+WJG_rang)*KxMax;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.tStart=VCtl.CV4+VCtl.delta_TE*5;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KxdK*VCtl.ResFreq/6*2*1;
[GAmpG4,GTimeG4]=GxAreaTrapezoid2(p);
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
%%%%%%%%%%%%%%%%%%%%%%%%%%
% add the random to the pulse    -2%~+2%
% WJG_rang =randi([-100,100],1)*3/100/100;

% p.GxAmp = (1+WJG_rang)*p.GxAmp;
%%%%%%%%%%%%%%%%%%%%%%%%%%
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
GAmp=[GAmpG1*Gx2Sign,GAmpG2*Gx1Sign,GAmpG3*Gx2Sign,GAmpG4*Gx1Sign,GAmp1*Gx1Sign GAmp2*Gx2Sign];
GTime=[GTimeG1,GTimeG2,GTimeG3,GTimeG4,GTime1 GTime2];
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end
