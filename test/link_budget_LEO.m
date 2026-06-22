clear;
clc;
close all;

c   = 3e8;
GM  = 3.986e14;
Re  = 6.371e6;
fc  = 920e6;
h   = 540e3;
v_sat = sqrt(GM / (Re + h));

t = -450 : 0.1 : 450;
r  = sqrt(h^2 + (v_sat .* t).^2);
El = atan2(h, abs(v_sat .* t));
El_min = 10 * pi/180;
visible = El >= El_min;

t_vis  = t(visible);
r_vis  = r(visible);
El_vis = El(visible) * 180/pi;

Pt_mW = 20;
Pt_dBm = 10*log10(Pt_mW);
Gt = 3.0;
Gr = 6.0;
NF = 4.0;
BW = 100e3;

lambda = c / fc;
FSPL = 20*log10(4*pi*r_vis/lambda);
Pr_dBm = Pt_dBm + Gt + Gr - FSPL;

SF_list = 7:12;
SNR_req = [-7.5 -10 -12.5 -15 -17.5 -20];
Sensitivity = -174 + 10*log10(BW) + NF + SNR_req;

font_size = 16;

figure;
subplot(2,1,1);
plot(El_vis, Pr_dBm, 'b', 'LineWidth', 1.5); hold on;
colors = lines(length(SF_list));
for i = 1:length(SF_list)
    yline(Sensitivity(i), '--', 'Color', colors(i,:));
end
grid on;
xlabel('elevation angle [deg]'); ylabel('received power [dBm]');
title('Received Power vs Sensitivity');
legend(['Pr', "SF=" + string(SF_list)], 'Location', 'best');
set(gca, 'FontSize', font_size);

subplot(2,1,2);
hold on;
for i = 1:length(SF_list)
    Margin = Pr_dBm - Sensitivity(i);
    plot(El_vis, Margin, 'LineWidth', 1.5, 'Color', colors(i,:));
end
yline(0, '--k');
grid on;
xlabel('elevation angle [deg]'); ylabel('link margin [dB]');
title('Link Margin vs Elevation Angle');
legend("SF=" + string(SF_list), 'Location', 'best');
set(gca, 'FontSize', font_size);

fprintf('Worst-case range        : %.1f km\n', max(r_vis)/1e3);
fprintf('Worst-case Pr            : %.1f dBm\n', min(Pr_dBm));
for i = 1:length(SF_list)
    fprintf('SF=%d  Sensitivity=%.1f dBm  Worst-case Margin=%.1f dB\n', ...
        SF_list(i), Sensitivity(i), min(Pr_dBm)-Sensitivity(i));
end