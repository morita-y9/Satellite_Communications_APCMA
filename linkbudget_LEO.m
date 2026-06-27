%LEOにおけるリンクバジェット計算
%現在は受信アンテナ利得を6.5dBiとしている

clear; 
clc; 
close all;

c   = 3e8;
GM  = 3.986e14;
Re  = 6.371e6;
fc  = 920e6;
h   = 540e3;

k  = 1.380649e-23;
T0 = 300;
BW = 100e3;

Pt_mW = 20;
Pt_dBm = 10*log10(Pt_mW);
Gt = 1;
Gr = 6.5;
NF = 4.0;
Pol_loss = 3.0;

N0_dBm_Hz = 10*log10(k*T0*1000);

El = linspace(1, 90, 200);
d  = sqrt((Re+h)^2 - (Re*cosd(El)).^2) - Re*sind(El);
lambda = c/fc;
FSPL = 20*log10(4*pi*d/lambda);
Pr_dBm = Pt_dBm + Gt + Gr - FSPL - Pol_loss;

SF_list = [7 9 10 11 12];
SNR_req = [-7.5 -12.5 -15 -17.5 -20];
Sensitivity = N0_dBm_Hz + 10*log10(BW) + NF + SNR_req;

figure;
hold on;
colors = lines(length(SF_list));
for i = 1:length(SF_list)
    Margin = Pr_dBm - Sensitivity(i);
    plot(El, Margin, 'LineWidth', 1.5, 'Color', colors(i,:));
end
yline(0, '-k', 'LineWidth', 1.5);
grid on;
xlabel('elevation angle [deg]');
ylabel('link margin [dB]');
title('Link Margin vs Elevation Angle');
legend("SF="+string(SF_list), 'Location', 'best');

fprintf('N0 (per Hz)          = %.2f dBm/Hz\n', N0_dBm_Hz);
fprintf('Noise floor (100kHz) = %.2f dBm\n', N0_dBm_Hz + 10*log10(BW));
fprintf('Pt_dBm               = %.2f dBm\n', Pt_dBm);
fprintf('Pr El=10deg        = %.2f dBm\n', Pr_dBm(find(El>=10,1)));
fprintf('Pr El=90deg        = %.2f dBm\n', Pr_dBm(end));