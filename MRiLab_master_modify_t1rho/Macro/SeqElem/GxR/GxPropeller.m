
function [GAmp,GTime]=GxPropeller(p)

global VCtl;
global VObj;
global VVar;

theta =pi/VCtl.EPI_ShotNum*(VVar.PhaseCount-1);
t1Start=p.t1Start;
t2Middle=p.t2Middle;
Gx1Sign=p.Gx1Sign;
Gx2Sign=p.Gx2Sign;

% frequency encoding
KxMax=(1/VCtl.RFreq)/2;

% prephasing lob
p.tStart=t1Start;
p.Area=KxMax;
p.Duplicates=1;
p.DupSpacing=0;
[GAmp1,GTime1]=GxAreaTrapezoid2(p);
GAmp1 = GAmp1.*cos(theta);

%blip
% prephasing lob
p=[];
KyMax=(1/VCtl.RPhase)/2/VCtl.EPI_ShotNum;
KydK=(2*KyMax)/VCtl.EPI_ETL;

% prephasing lob
p.tStart=GTime1(end)+0.5e-3;
p.Duplicates=1;
p.DupSpacing=0;
p.Area=KyMax;
[GAmp1_1,GTime1_1]=GyAreaTrapezoid2(p);
GAmp1_1 = GAmp1_1.*-sin(theta);
GAmp1 = [GAmp1,GAmp1_1];
GTime1 = [GTime1,GTime1_1];

p=[];


%%%% blip lobs
pb=[];
pb.Area=KydK;
pb.Duplicates=1;
pb.DupSpacing=0;
pb.tStart=0;
[GAmptb,GTimetb]=GyAreaTrapezoid2(pb);
GTimetb =GTimetb-GTimetb(1);
GAmptb =GAmptb.* -sin(theta);
pb.duration = GTimetb(4)-GTimetb(1);


% readout lobs
p.GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*p.GxAmp*VCtl.RFreq);

TimeOffset = (t2Middle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)+0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
p.tRamp = VCtl.EPI_ESP/2 - tHalf-pb.duration/2;
p.sRamp = 2;
p.Duplicates=1;
p.DupSpacing=0;
GAmp2=[];
GTime2=[];
for i = 1: VCtl.EPI_ETL
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP + p.tRamp;
    p.tEnd = p.tStart + 2 * tHalf;
    [GAmpt,GTimet]=GxTrapezoid(p);
    GAmpt = GAmpt.*cos(theta);
    GAmp2=[GAmp2 GAmpt*(-1)^(i-1) GAmptb];
    GTimetbt = GTimet(4)+GTimetb;
    GTime2=[GTime2 GTimet GTimetbt];
end

GAmp=[GAmp1*Gx1Sign GAmp2*Gx2Sign];
GTime=[GTime1 GTime2];

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);
GAmp(end-3:end)=0;

end
