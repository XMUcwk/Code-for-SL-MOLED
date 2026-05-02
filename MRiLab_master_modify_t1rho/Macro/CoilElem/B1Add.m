
function dB1=B1Add(p)
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

dB1=(xgrid.*GradX+ ygrid.*GradY+zgrid.*GradZ).*Scale;

   
end
