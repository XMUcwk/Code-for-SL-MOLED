
function [GAmp,GTime]=ADCPropeller(p)

global VCtl;
global VObj;
global VVar;

%%%% blip lobs
pb=[];
KyMax=(1/VCtl.RPhase)/2;
KydK=(2*KyMax)/VCtl.EPI_ETL/VCtl.EPI_ShotNum;
pb.Area=KydK;
pb.Duplicates=1;
pb.DupSpacing=0;
pb.tStart=0;
[GAmptb,GTimetb]=GyAreaTrapezoid2(pb);
GTimetb =GTimetb-GTimetb(1);
GAmptb =GAmptb.* -sin(pi/6);
pb.duration = GTimetb(4)-GTimetb(1);

tMiddle=p.tMiddle;

% acqusition lobs
GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*VCtl.RFreq);

TimeOffset = (tMiddle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)+0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
tRamp = VCtl.EPI_ESP/2 - tHalf-pb.duration/2;
p.sSample = VCtl.ResFreq;
p.Duplicates=1;
p.DupSpacing=0;
GAmp=zeros(1, VCtl.EPI_ETL * (VCtl.ResFreq + 2));
GTime=zeros(1, VCtl.EPI_ETL * (VCtl.ResFreq + 2));
for i = 1: VCtl.EPI_ETL
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP + tRamp;
    p.tEnd = p.tStart + 2 * tHalf;
    [GAmpt,GTimet]=ADCBlock(p);
    GAmp((i-1)*(VCtl.ResFreq + 2)+1 : i*(VCtl.ResFreq + 2))=GAmpt;
    GTime((i-1)*(VCtl.ResFreq + 2)+1 : i*(VCtl.ResFreq + 2))=GTimet;
end

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end




