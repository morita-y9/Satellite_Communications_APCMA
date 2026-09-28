clear; clc; close all;
c   = 3e8;
GM  = 3.986e14;
Re  = 6.371e6;
fc  = 920e6;
h   = 540e3;
k_dB = -228.6;
Pt_mW = 20;
Gt   = 1.0;
Gr0  = 6.0;
NR   = 9;
NF   = 4.0;
T0   = 290;
BW   = 100e3;
HPBW = 80;
L_margin = 6.0;
font_size = 60;

Pt_dBW = 10*log10(Pt_mW/1000);
EIRP   = Pt_dBW + Gt;

El   = linspace(1, 90, 500);
El_r = El * pi/180;

d      = sqrt((Re+h)^2 - (Re*cos(El_r)).^2) - Re*sin(El_r);
lambda = c/fc;
FSPL   = 20*log10(4*pi*d/lambda);

gamma  = asin(Re*cos(El_r)/(Re+h)) * 180/pi;
L_scan = 12 * (gamma/HPBW).^2;

Gr_eff = Gr0 + 10*log10(NR) - L_scan;
T_sys  = T0 * 10^(NF/10);
GT     = Gr_eff - 10*log10(T_sys);

CNo = EIRP - FSPL + GT - k_dB - L_margin;
SNR = CNo - 10*log10(BW);

SF_list = [7 10 12];
SNR_req = [-7.5 -15 -20];

figure;
plot(El, SNR, 'k', 'LineWidth', 2);
hold on;
colors = lines(length(SF_list));
for i = 1:length(SF_list)
    plot(El, SNR_req(i)*ones(size(El)), '--', 'Color', colors(i,:), 'LineWidth', 3.0);
end
grid on;
xlabel('elevation angle [deg]'); ylabel('SNR [dB]');
title('Received SNR');
legend(['Received SNR', arrayfun(@(s) sprintf('SF=%d', s), SF_list, 'UniformOutput', false)], ...
       'Location', 'southeast');
set(gca, 'FontSize', font_size);
hold off;

for i = 1:length(SF_list)
    idx = find(SNR >= SNR_req(i), 1);
    if isempty(idx)
        fprintf('SF%-2d : not closed\n', SF_list(i));
    else
        fprintf('SF%-2d : closes above %.1f deg\n', SF_list(i), El(idx));
    end
end
fprintf('Slant range at 10 deg    : %.0f km\n', ...
        interp1(El, d, 10)/1e3);
fprintf('Scan loss at 10 deg      : %.1f dB\n', interp1(El, L_scan, 10));
fprintf('SNR at 10 deg            : %.1f dB\n', interp1(El, SNR, 10));
fprintf('SNR at 90 deg            : %.1f dB\n', SNR(end));