%created by angus
% 2019.5.1
function B1 = WJG_B1_rand()
global VObj
global VMco
global VCtl
% if VCtl.SliceThick~=VObj.ZDimRes
%     error('only one slice can be selected. WJG_B1_rand.m');
% end
Mxdims=size(VObj.Rho);
                        
if (length(size(Mxdims))==2)||(Mxdims(3) ==1)
    Mxdims(3) = 1;
    mxgrid = linspace(-1/2,1/2,Mxdims(2));
    mygrid = linspace(-1/2,1/2,Mxdims(1));
    mzgrid = 1e-10;
    [VMco.xgrid,VMco.ygrid,VMco.zgrid]=meshgrid(mxgrid,mygrid,mzgrid);   
else
    [VMco.xgrid,VMco.ygrid,VMco.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VObj.XDimRes*(1/Precision):((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                            (-(Mxdims(1)-1)/2)*VObj.YDimRes:VObj.YDimRes*(1/Precision):((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                            (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VObj.ZDimRes:((Mxdims(3)-1)/2)*VObj.ZDimRes);   
end

xishu_0=0.2*randi(10000)/10000-0.1;
xishu_x1=normrnd(0,0.5);
xishu_y1=normrnd(0,0.5);
xishu_xy=1*randi(10000)/10000-0.5;


%% aX+bY+c
p.GradX=xishu_x1;
p.GradY=xishu_y1;

p.GradZ=0;
p.Scale=1;
dB1t=B1Linear(p);
B1=dB1t;
p=[];
%% XY
scale=1;
p.Equation=[num2str(scale*xishu_xy),'*X.*Y'];
dB1t=B1Symbolic(p);
B1=B1+dB1t;
p=[];
%% X^2
xishu_rand = 1*randi(10000)/10000-0.5;
p.Equation=[num2str(scale*xishu_rand),'*X.^2'];
dB1t=B1Symbolic(p);
B1=B1+dB1t;
p=[];
%% Y^2
xishu_rand = 1*randi(10000)/10000-0.5;
p.Equation=[num2str(scale*xishu_rand),'*Y.^2'];
dB1t=B1Symbolic(p);
B1=B1+dB1t;
%% X^3
xishu_rand = 1*randi(10000)/10000-0.5;
p.Equation=[num2str(scale*xishu_rand),'*X.^3'];
dB1t=B1Symbolic(p);
B1=B1+dB1t;
%% Y^3
xishu_rand = 1*randi(10000)/10000-0.5;
p.Equation=[num2str(scale*xishu_rand),'*Y.^3'];
dB1t=B1Symbolic(p);
B1=B1+dB1t;

% figure(5);imshow(B1,[]);colormap jet;colorbar
ran_amp = 0.5*randi(10000)/10000;
B1 = B1./max(abs(B1(:)))*ran_amp+xishu_0+1.0;
% figure(34);imshow(B1,[]);colormap jet;colorbar
end
