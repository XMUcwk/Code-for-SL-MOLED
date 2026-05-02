
function ExecFlag=DoImgRecon(Simuh)

global VCtl;
global VImg;

ExecFlag = 1;
TmpVImg = VImg;

try
    VImg = []; % clear VImg
    switch VCtl.ReconEng
        case 'Default'
            switch VCtl.ReconType
                case 'Cartesian'
                    if isfield(VCtl,'chirp') % chirp
                        DochirpRecon(Simuh);
                    elseif isfield(VCtl,'oledMM') % oledMM
                        DoOLEDMMRecon(Simuh);
                    elseif isfield(VCtl,'oledSM') % oledSM
                        DoOLEDSMRecon(Simuh);
					elseif isfield(VCtl,'LLOLED_Slice') % LLOLED
                        DoLLOLEDRecon(Simuh);
                    elseif isfield(VCtl,'point') % oledSM
                        DoCartRecon(Simuh);
                    elseif isfield(VCtl,'EPI_ShotNum') % EPI
                        DoEPIRecon(Simuh);
                    elseif isfield(VCtl,'FSE_ShotNum') % FSE
                        DoFSERecon(Simuh);
                    
                    else                           % normal Cartesian
                        DoCartRecon(Simuh);
                    end
                    
                case 'NonCart'
                    DoNonCartRecon(Simuh);
            end
        case 'External'
            eval([VCtl.ExternalEng ';']);
    end
    
catch me
    %%  Saving output
    DoUpdateInfo(Simuh,'Saving signal data & info...');
    DoSaveOutput(Simuh);
    DoUpdateInfo(Simuh,'Signal data saving is complete!');
    
    ExecFlag = 0;
    VImg = TmpVImg;
    error_msg{1,1}='ERROR!!! Recon process aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end


end