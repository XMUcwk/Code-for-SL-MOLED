
function dB1=B1Linear(p)
%create dB1 field

global VMco

% Initialize parameters
GradX=p.GradX;
GradY=p.GradY;
GradZ=p.GradZ;
Scale=p.Scale;

% Initialize display grid
xgrid=VMco.xgrid;
ygrid=VMco.ygrid;
zgrid=VMco.zgrid;
%ygrid = abs(ygrid);
dB1=(xgrid.*GradX+ygrid.*GradY+zgrid.*GradZ).*Scale;
% size(dB1)
end
