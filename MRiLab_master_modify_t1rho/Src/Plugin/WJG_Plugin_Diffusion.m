
function WJG_Plugin_Diffusion
global VObj
global VCtl
global WJG_Bvalue_idx
Bvalue = VCtl.Bvalue;
Bvalue_num = length(Bvalue);
current_Bvalue = Bvalue(WJG_Bvalue_idx);
WJG_Bvalue_idx = mod(WJG_Bvalue_idx,Bvalue_num)+1;
% Using default matlab command always causes crash and error... don't know why!!!
% Using Mex function (with matrix pointer) solve the peoblem.
% Bug fixed on May-3rd-2013, now it's safe to use matlab command.
% Must update matrix pointer before returning to Mex after matlab matrix operation.
    if isfield(VObj,'WJG_ADC_star')  %ivim
        signal_decay = VObj.WJG_F.*exp(-current_Bvalue*VObj.WJG_ADC_star)+(1-VObj.WJG_F).*exp(-current_Bvalue*VObj.WJG_ADC);
        VObj.Mx=VObj.Mx.*signal_decay;
        VObj.My=VObj.My.*signal_decay;
    else 
        %traditional diffusion
        VObj.Mx=VObj.Mx.*exp(-current_Bvalue*VObj.WJG_ADC);
        VObj.My=VObj.My.*exp(-current_Bvalue*VObj.WJG_ADC); 
   end
    



end
