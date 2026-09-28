clear; clc;

fsize = 24;
lw    = 2.0;

Pt_dBm    = 13.0;
Gt_dBi    = 1.0;
Gr0_dBi   = 6.0;
NR        = 9;
NF_dB     = 4.0;
HPBW_deg  = 80.0;
BW_Hz     = 100e3;
fc_Hz     = 920e6;
h_km      = 540;
Re_km     = 6371;
T_ant_K   = 290;
T0_K      = 290;
k_dB      = -228.6;

L_margin_dB    = 6.0;
L_sysmargin_dB = 6.0;

SF_list     = [7 10 12];
SNRreq_list = [-7.5 -15.0 -20.0];

el_target_deg = 10;
el_deg = linspace(5, 90, 500);

G_array_dB = 10*log10(NR);
EIRP_dBW   = (Pt_dBm - 30) + Gt_dBi;

F_lin  = 10^(NF_dB/10);
Tsys_K = T_ant_K + T0_K*(F_lin - 1);
GT_dBK = (Gr0_dBi + G_array_dB) - 10*log10(Tsys_K);

el_rad  = deg2rad(el_deg);
d_km    = -Re_km*sin(el_rad) + sqrt((Re_km*sin(el_rad)).^2 + h_km^2 + 2*Re_km*h_km);
FSPL_dB = 20*log10(4*pi*(d_km*1e3)*fc_Hz/3e8);

gamma_deg = rad2deg(asin(Re_km*cos(el_rad)/(Re_km + h_km)));
L_scan_dB = 12*(gamma_deg/HPBW_deg).^2;

CN0_dB = EIRP_dBW - FSPL_dB - L_scan_dB - L_margin_dB + GT_dBK - k_dB;
SNR_dB = CN0_dB - 10*log10(BW_Hz);

figure; hold on; grid on;
plot(el_deg, SNR_dB, 'k', 'LineWidth', lw, 'DisplayName', 'Received SNR');
colors = lines(length(SF_list));

hold on;

plot(El, SNR, 'k-', 'LineWidth', 2.5, 'DisplayName', 'Received SNR');

for i = 1:length(SF_list)
    yline(SNR_req(i), '--', sprintf('SF=%d', SF_list(i)), ...
        'LineWidth', 1.8, 'Color', colors(i,:), ...
        'FontSize', fontSize-10, 'LabelHorizontalAlignment', 'left', ...
        'HandleVisibility', 'off');
end

grid on;
xlabel('Elevation angle [deg]', 'FontSize', fontSize);
ylabel('SNR [dB]', 'FontSize', fontSize);
title('SNR vs Elevation Angle', 'FontSize', fontSize);
legend('Location', 'southeast', 'FontSize', fontSize-2);
hold off;
