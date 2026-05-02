
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfSinc(p)
%create a sinc rf pulse starting from tStart and ending at tEnd
%tStart rf start time
%tEnd rf end time
%FA rf actual flip angle
%dt rf sample time
%TBP time-bandwidth product
%Apod apodization flag
%rfPhase rf phase
%rfFreq rf off-res freq

tStart=p.tStart;
tEnd=p.tEnd;

FA=p.FA;
dt=p.dt;
rfPhase=p.rfPhase;
rfFreq=p.rfFreq;
rfCoil=p.CoilID;
Apod=p.Apod;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

switch Apod % Apodization
    case 'Non' % non
        a=0;
    case 'Hamming' % Hamming
        a=0.46;
    case 'Hanning' % Hanning
        a=0.5;
end


%% read rf file from varian
filename = p.rf_file;
content = textread(filename,'%s','delimiter','\n');
Resolution = 4e-7;
Duration_flag = 0;
for loopi = 1:length(content)
    temp_text = content{loopi};
    if findstr(temp_text,'Resolution')
        Resolution = regexp(temp_text,' ','split');
        Resolution = str2num(Resolution{end-1})/1000/1000;
        if abs(Resolution-dt)>2*eps
            error_msg{1,1}='The dt is not consistent with that of experimental rf. Please check!';
            warndlg(error_msg);
        end
    end 
    if findstr(temp_text,'Duration')
        Duration = regexp(temp_text,' ','split');
        Duration = str2num(Duration{end-1})/1000;
        Duration_flag = 1;
        if abs(Duration-(tEnd-tStart))>2*eps
            error_msg{1,1}='The duration is not consistent with that of experimental rf. Please check!';
            warndlg(error_msg);
        end
    end
    if findstr(temp_text,'***************************')
        start_idx  = loopi+1;
    end  

end
if Duration_flag == 0 
    error_msg{1,1}='The default resolution of rf is 4 us. Please pay more attention to it!';
    warndlg(error_msg);
end
steps = length(content)-start_idx+1;
Duration = Resolution*(steps-1);

dt = (tEnd-tStart)/steps;
rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1);
rfTime=rfTime-(tEnd-tStart)/2-tStart;

rfAmp = zeros(1,length(content)-start_idx+2);
for loopi = start_idx:length(content)
    temp_rf  = str2num(content{loopi});
    temp_amp = temp_rf(2).*cos(temp_rf(1)/180*pi);
    rfAmp(loopi-start_idx+1) = temp_amp;    
end

rfAmp(isnan(rfAmp))=max(rfAmp);
rfAmp(1)=0;
rfAmp(end)=0;
rfAmp=DoB1Scaling(rfAmp,dt,FA)*rfAmp; %B1 Scaling
rfTime=rfTime+(tEnd-tStart)/2+tStart;

rfPhase=(rfPhase)*ones(size(rfTime));
rfFreq=(rfFreq)*ones(size(rfTime));
rfCoil=(rfCoil)*ones(size(rfTime));
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
