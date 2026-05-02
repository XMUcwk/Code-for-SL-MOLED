%%%% 2022.1.5 cwk
%%%% 20220602 consider B0 B1, modified by lq
% T1rho T2rho reference paper"near-resonance spin-lock contrast" 
function LQ_Plugin_T1rho
global VObj
global VCtl
% global VSig
global LQ_TSL_idx
TSL = VCtl.TSL;

%% 
% TSL_num = length(TSL);
% disp('t1rho');
% TSL = TSL1(LQ_TSL_idx);

% LQ_TSL_idx = mod(LQ_TSL_idx,TSL_num)+1;
% Using default matlab command always causes crash and error... don't know why!!!
% Using Mex function (with matrix pointer) solve the peoblem.
% Bug fixed on May-3rd-2013, now it's safe to use matlab command.
% Must update matrix pointer before returning to Mex after matlab matrix operation.
%         VObj.Mx=VObj.Mx.*exp(-current_TSL./VObj.T1rho);
%         VObj.My=VObj.My.*exp(-current_TSL./VObj.T1rho);

%% don't consider B0 B1 T2rho
%  VObj.Mz=VObj.Mz.*exp(-current_TSL./(VObj.T1rho)); %cwk

%% consider B0 B1 T2rho
B1 = VObj.B1;
% B1 = symmetrize_matrix(B1);
alpha = (pi/2)*VObj.B1;
beta = (pi)*VObj.B1;
dB0 = VObj.B0;%VObj.B0_2
FSL = VCtl.wSL;  %unit Hz
if (VCtl.wSL==0) || (TSL==0)
    theta = 0;
else
    theta = atan(dB0./(FSL*VObj.B1));
end
% disp('t1rho4');
% figure();imagesc(VObj.T2);colormap jet;colorbar;title('VObj.T2');
% figure();imagesc(VObj.T1);colormap jet;colorbar;title('VObj.T1');


R1rho = (1./VObj.T1).*(sin(theta).^2)+(1./VObj.T2).*(cos(theta).^2);
R1rho(isnan(R1rho)) = 0;
R1rho(isinf(R1rho)) = 0;

R2rho = 0.5*(1./VObj.T2+(1./VObj.T1).*(cos(theta).^2)+(1./VObj.T2).*(sin(theta).^2));
R2rho(isnan(R2rho)) = 0;
R2rho(isinf(R2rho)) = 0;
% disp('t1rho5');
% R2rho(R2rho>100) = 0;
% figure();imagesc(R1rho);colormap jet;colorbar;title('R1rho');
% figure();imagesc(R2rho);colormap jet;colorbar;title('R2rho');

% decay_rate = (exp(-TSL*R1rho).*(sin(alpha).^2).*(cos(theta).^2)+exp(-TSL*R2rho).*(cos(alpha).^2).*cos(beta).*(sin(theta).^2)); %wrong
% figure();imagesc(ratio);colormap jet;colorbar;title('decay rate');
% VObj.Mz=VObj.Mz.*(decay_rate);
% VSig.Mz=VSig.Mz.*(decay_rate);

T1rho = 1./R1rho;
T1rho(isnan(T1rho)) = 0;
T1rho(isinf(T1rho)) = 0;
T2rho = 1./R2rho;
T2rho(isnan(T2rho)) = 0;
T2rho(isinf(T2rho)) = 0;
VObj.T1rho = T1rho;
VObj.T2rho = T2rho;
% disp('t1rho6');
% temp = size(VObj.Mz);
% figure;imagesc(VObj.Mz(:,:,1,1));title('Mz');
% figure;imagesc(VObj.Mx(:,:,1,1));title('Mx');
% figure;imagesc(VObj.My(:,:,1,1));title('My');
% disp(temp);
row = 500;
col = 500;
M0(:,:,1) = zeros(row,row);%X
M0(:,:,2) = zeros(row,row);%Y
M0(:,:,3) = ones(500,500);%Z
% disp('t1rho2');

wSL = 2*pi*VCtl.wSL; % frequency of the SL pulse (radian/s)
del_w0 = 2*pi*VObj.B0;  %magnetic field inhomogeneity(radian/s)   2*pi*VObj.B0_2
weff_SL=sqrt((B1.*wSL).^2+del_w0.^2); %effective frequency of the SL pulse
fai_SL=atan(B1.*wSL./del_w0);  % (radian)
parfor r = 1:row
    for c = 1:col
%         T1rho_out(r,c,:) = T1rho_STD(dB0(r,c),B1(r,c),squeeze(M0(r,c,:)),FSL,TSL,T1rho(r,c),T2rho(r,c));
         T1rho_out(r,c,:) = M_STD_SL(B1(r,c),weff_SL(r,c),TSL,fai_SL(r,c),T1rho(r,c),T2rho(r,c),squeeze(M0(r,c,:)));
    end
end

 %figure;imagesc(T1rho_out(:,:,3));title('T1rho out');
VObj.Mz = VObj.Mz.*T1rho_out(:,:,3);
% disp('t1rho3');
% figure;imagesc(VObj.Mz(:,:,1,1));title('Mz2');
% figure();imagesc(T1rho);colormap jet;colorbar;title('T1rho');
% figure();imagesc(T2rho);colormap jet;colorbar;title('T2rho');
end




function  out = M_STD_SL(B1,weff_SL,TSL,fai_SL,T1rho,T2rho,M0)
out = Ry(-pi/2)*Rz(-B1*pi/2)*Ry(pi/2)*Ry_pie(-weff_SL,TSL/2,fai_SL,T1rho,T2rho)*Rx(-pi/2)*Rz(B1*pi)*Rx(pi/2)*Ry_pie(weff_SL,TSL/2,fai_SL,T1rho,T2rho)*Ry(-pi/2)*Rz(B1*pi/2)*Ry(pi/2)*M0;
end

%% Rx
function Rx_Out = Rx(alpha)
    Rx_Out = [1 0 0;0 cos(alpha) sin(alpha);0 -sin(alpha) cos(alpha)];
end
%% Ry
function Ry_Out = Ry(alpha)
    Ry_Out = [cos(alpha) 0 -sin(alpha);0 1 0;sin(alpha) 0 cos(alpha)];
end
%% Rz
function Rz_Out = Rz(alpha)
    Rz_Out = [cos(alpha) sin(alpha) 0;-sin(alpha) cos(alpha) 0;0 0 1];
end
%% Ep
function Ep_Out = Ep(tau,T1rho,T2rho)
    Ep_Out = [exp(-tau./T2rho) 0 0;0 exp(-tau./T2rho) 0;0 0 exp(-tau./T1rho)];
end
%% Rx'
function Rx_pie_Out = Rx_pie(weff,tau,fai)
    Rx_pie_Out = Ry(-fai)*Rz(weff*tau)*Ry(fai);
end
%% Ry'
function Ry_pie_Out = Ry_pie(weff,tau,fai,T1rho,T2rho)
    Ry_pie_Out = Rx(-fai)*Rz(weff*tau)*Ep(tau,T1rho,T2rho)*Rx(fai);
end

%% 
% function M_STD = T1rho_STD(dB0,B1,M0,FSL,TSL,T1rho,T2rho)
% M1 = Ry(-pi/2)*Rz(B1*pi/2)*Ry(pi/2)*M0;
% wSL_eff = sqrt((FSL*B1).^2+dB0.^2);
% phi_SL = atan(FSL*B1./dB0);
% M2 = Rx(-phi_SL)*Rz(wSL_eff*TSL/2)*Ep(TSL/2,T1rho,T2rho)*Rx(phi_SL)*M1;
% M3 = Rx(-pi/2)*Rz(B1*pi)*Rx(pi/2)*M2;
% M4 = Rx(-phi_SL)*Rz(-wSL_eff*TSL/2)*Ep(TSL/2,T1rho,T2rho)*Rx(phi_SL)*M3;
% M_STD = Ry(-pi/2)*Rz(-B1*pi/2)*Ry(pi/2)*M4;
% end
% 
% %% 
% function Rx_Out = Rx(alpha)
% Rx_Out = [1 0 0;0 cos(alpha) sin(alpha);0 -sin(alpha) cos(alpha)];
% end
% %% 
% function Ry_Out = Ry(alpha)
% Ry_Out = [cos(alpha) 0 -sin(alpha);0 1 0;sin(alpha) 0 cos(alpha)];
% end
% %% 
% function Rz_Out = Rz(alpha)
% Rz_Out = [cos(alpha) sin(alpha) 0;-sin(alpha) cos(alpha) 0;0 0 1];
% end
% %%
% function Ep_Out = Ep(tau,T1rho,T2rho)
%     Ep_Out = [exp(-tau./T2rho) 0 0;0 exp(-tau./T2rho) 0;0 0 exp(-tau./T1rho)];
% end
%% 
% function A = symmetrize_matrix(A)
%     % 对称化矩阵中的0-1范围内的值至大于1，原来大于1以及等于0的值保持不变
%     % 输入:
%     %   A: 待对称化的矩阵
%     % 输出:
%     %   A: 对称化后的矩阵
% 
%     % 将小于0的值设为0
%     A(A < 0) = 0;
%     
%     % 找到0到1范围内的值
%     idx = (A > 0) & (A < 1);
%     
%     % 将这些值设为其与1之差的绝对值
%     A(idx) = 2-A(idx);
%     
%     % 不对大于1和等于0的值做处理
%     A((A >= 1) | (A == 0)) = A((A >= 1) | (A == 0));
% end