
function [GAmp,GTime]=ADCEPI(p)

global VCtl;
global VObj;
global VVar;
%%%%%%%%%%%%%%%%%seq1
tMiddle=p.tMiddle;

% acqusition lobs
GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*VCtl.RFreq);

TimeOffset = (tMiddle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)+0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
tRamp = VCtl.EPI_ESP/2 - tHalf;
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

%%%%%%%%%%%%%%%%%seq2
tMiddle = 2*VCtl.Refocus-VCtl.TE;

% acqusition lobs
GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*VCtl.RFreq);

TimeOffset = (tMiddle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)+0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
tRamp = VCtl.EPI_ESP/2 - tHalf;
p.sSample = VCtl.ResFreq;
p.Duplicates=1;
p.DupSpacing=0;
GAmp1=zeros(1, VCtl.EPI_ETL * (VCtl.ResFreq + 2));
GTime1=zeros(1, VCtl.EPI_ETL * (VCtl.ResFreq + 2));
for i = 1: VCtl.EPI_ETL
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP + tRamp;
    p.tEnd = p.tStart + 2 * tHalf;
    [GAmpt,GTimet]=ADCBlock(p);
    GAmp1((i-1)*(VCtl.ResFreq + 2)+1 : i*(VCtl.ResFreq + 2))=GAmpt;
    GTime1((i-1)*(VCtl.ResFreq + 2)+1 : i*(VCtl.ResFreq + 2))=GTimet;
end
%%%%%%%%%%%%%%%%%seq3
tMiddle=VCtl.T1TE;

% acqusition lobs
GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*VCtl.RFreq);

TimeOffset = (tMiddle+VCtl.TEAnchorTime)-(floor(VCtl.EPI_ETL/2)+0.5)*VCtl.EPI_ESP;
if strcmp(VCtl.EPI_EchoShifting,'on')
     TimeOffset = TimeOffset + (VVar.PhaseCount-1)*(VCtl.EPI_ESP/VCtl.EPI_ShotNum);
end
tRamp = VCtl.EPI_ESP/2 - tHalf;
p.sSample = VCtl.ResFreq;
p.Duplicates=1;
p.DupSpacing=0;
GAmp2=zeros(1, VCtl.EPI_ETL * (VCtl.ResFreq + 2));
GTime2=zeros(1, VCtl.EPI_ETL * (VCtl.ResFreq + 2));
for i = 1: VCtl.EPI_ETL
    p.tStart = TimeOffset + (i-1)*VCtl.EPI_ESP + tRamp;
    p.tEnd = p.tStart + 2 * tHalf;
    [GAmpt,GTimet]=ADCBlock(p);
    GAmp2((i-1)*(VCtl.ResFreq + 2)+1 : i*(VCtl.ResFreq + 2))=GAmpt;
    GTime2((i-1)*(VCtl.ResFreq + 2)+1 : i*(VCtl.ResFreq + 2))=GTimet;
end
%%%%%%%%%%%%%%%%%%%%%%%
[GTime,m,n]=unique([GTime,GTime1,GTime2]);
GAmp = [GAmp,GAmp1,GAmp2];
GAmp=GAmp(m);

end




