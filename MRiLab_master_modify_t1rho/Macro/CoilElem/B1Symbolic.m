
function dB1=B1Symbolic(p)
%create dB1 field

global VMco

% Initialize parameters
Equation=p.Equation;

% Initialize display grid
X=VMco.xgrid;
Y=VMco.ygrid;
Z=VMco.zgrid;

try
    eval(['dB1=' Equation ';']);
catch me
    dB1 = zeros(size(VMco.xgrid));
    error_msg{1,1}='ERROR!!! Creating dB1 field using symbolic equation fails!';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end

end
