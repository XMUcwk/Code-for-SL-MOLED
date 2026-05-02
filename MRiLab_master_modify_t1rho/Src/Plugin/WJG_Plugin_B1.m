% B2 is similar to B1, B2 is the rf field of 180 pulse 
function WJG_Plugin_B1
global WJG_Coi_B1          %record the old coi
global WJG_Coi_B2          %record the old coi
global VCoi
% Using default matlab command always causes crash and error... don't know why!!!
% Using Mex function (with matrix pointer) solve the peoblem.
% Bug fixed on May-3rd-2013, now it's safe to use matlab command.
% Must update matrix pointer before returning to Mex after matlab matrix operation.
if  (isempty(WJG_Coi_B1))
        WJG_Coi_B1 = VCoi.TxCoilmg;
        disp("did you added B2? ")
else
   VCoi.TxCoilmg=WJG_Coi_B1; % total B+ field magnitude after normalization
end
end
