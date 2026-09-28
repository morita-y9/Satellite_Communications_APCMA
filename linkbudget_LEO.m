Pt_mW    = 20;
Gt       = 1.0;
Gr0      = 6.0;
NR       = 9;
NF       = 4.0;
T0       = 290;
BW       = 100e3;
fc       = 920e6;
h        = 540e3;
Re       = 6.371e6;
GM       = 3.986e14;
c_light  = 3e8;
k_dB     = -228.6;
fontSize = 60;
HPBW     = 80;
L_margin = 6.0;

Pt_dBW = 10*log10(Pt_mW/1000);
EIRP   = Pt_dBW + Gt;

El   = linspace(1, 90, 500);
El_r = El * pi/180;

d_m    = sqrt((Re+h)^2 - (Re*cos(El_r)).^2) - Re*sin(El_r);
lambda = c_light/fc;
FSPL   = 20*log10(4*pi*d_m/lambda);

gamma_sat = asin(Re * cos(El_r) / (Re+h));
L_scan    = 12 * (gamma_sat*180/pi / HPBW).^2;

Gr_array = Gr0 + 10*log10(NR);
Gr_eff   = Gr_array - L_scan;

T_sys = T0 * 10^(NF/10);
GT    = Gr_eff - 10*log10(T_sys);

CNo = EIRP - FSPL + GT - k_dB - L_margin;
SNR = CNo - 10*log10(BW);

SF_list = [7 10 12];
SNR_req = [-7.5 -15 -20];

figure;
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