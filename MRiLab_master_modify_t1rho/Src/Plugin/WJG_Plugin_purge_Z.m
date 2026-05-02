
function WJG_Plugin_purge_Z
global VObj

% Using default matlab command always causes crash and error... don't know why!!!
% Using Mex function (with matrix pointer) solve the peoblem.
% Bug fixed on May-3rd-2013, now it's safe to use matlab command.
% Must update matrix pointer before returning to Mex after matlab matrix operation.

VObj.Mz=VObj.Mz.*0;

end
