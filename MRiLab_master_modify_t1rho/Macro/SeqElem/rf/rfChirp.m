
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfChirp(p)

%  <rfChirp AnchorTE="$2'on','off'" CoilID="1" DupSpacing="0" Duplicates="1" FA="90" Notes="customized rf pulse" O="48000" Switch="$1'on','off'" dt="10e-6" rfFile="'rfUserSinc'" rfPhase="0" tEnd="2e-3" tStart="10e-6"/>

tStart=p.tStart;
tEnd=p.tEnd;
dt=p.dt;
Amp = p.Amp;
rfCoil=p.CoilID;
O=p.O;

Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

Te = tEnd-tStart;
sw = O*2*pi;
Oi=sw/2;
R=sw/(tEnd-tStart);

rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1)-tStart;

rfAmp=(1-cos(pi*rfTime/Te).^40);


% wc=Oi+R*t;
rfFreq = (Oi-R*rfTime)/2/pi;
rfPhase=Oi*rfTime+R*rfTime.^2/2;
% pha_angle=rfPhase.*180./pi;
% rfPhase=mod(pha_angle,360)*pi/180;


ch_am = chirp(rfTime,-sw/2/2/pi,(Te/2),0);      %Hz

% rfAmp=DoB1Scaling(rfAmp,dt,FA)*rfAmp; %B1 Scaling

rfAmp(isnan(rfAmp))=max(rfAmp);
rfAmp = rfAmp*Amp;%90�?	32Khz  0.000018  64KHz  0.000025
%4KHz,180�?0.00000525
rfAmp(1)=0;
rfAmp(end)=0;
rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1);

rfPhase=(rfPhase).*zeros(size(rfTime));
% rfPhase = mod(rfPhase,2*pi);
rfFreq=(rfFreq).*ones(size(rfTime));
rfCoil=(rfCoil).*ones(size(rfTime));
rfPhase(1)=0;
rfPhase(end)=0;
rfFreq(1)=0;
rfFreq(end)=0;

% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    rfAmp=repmat(rfAmp,[1 Duplicates]);
    rfFreq=repmat(rfFreq,[1 Duplicates]);
    rfPhase=repmat(rfPhase,[1 Duplicates]);
    rfCoil=repmat(rfCoil,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[length(rfTime) 1]);
    rfTime=repmat(rfTime,[1 Duplicates]) + (TimeOffset(:))';
end

end