clear; 
clc; 
close all;

Pt_dBm = 13;
Gt_dBi = 1.0;
Gr_dBi = 2.0;
fc_Hz = 920e6;
BW_Hz = 100e3;
NF_dB = 6.0;
c = 3e8;

L_glass_per_pane_dB = 15;
N_glass_panes = 2;
L_margin_dB = 6.0;

d_target_m = 8200;

SNR_req_SF7 = -7.5;
SNR_req_SF10 = -15;
SNR_req_SF12 = -20;

d_m = linspace(1, 8200, 500);

FSPL_dB = 20*log10(4*pi*d_m*fc_Hz/c);
L_glass_total_dB = N_glass_panes * L_glass_per_pane_dB;

Pr_dBm = Pt_dBm + Gt_dBi + Gr_dBi - FSPL_dB - L_glass_total_dB - L_margin_dB;

N_dBm = -174 + 10*log10(BW_Hz) + NF_dB;

SNR_dB = Pr_dBm - N_dBm;

figure;
hold on;
plot(d_m, SNR_dB, 'LineWidth', 2, 'DisplayName', 'SNR');
plot(d_m, SNR_req_SF7*ones(size(d_m)), '--', 'LineWidth', 1.2, 'DisplayName', 'SF7 ');
plot(d_m, SNR_req_SF10*ones(size(d_m)), '--', 'LineWidth', 1.2, 'DisplayName', 'SF10 ');
plot(d_m, SNR_req_SF12*ones(size(d_m)), '--', 'LineWidth', 1.2, 'DisplayName', 'SF12　');
hold off;
grid on;
xlabel('Distance [m]');
ylabel('SNR [dB]');
title('SNR vs distance');
legend('show', 'Location', 'best');

FSPL_target_dB = 20*log10(4*pi*d_target_m*fc_Hz/c);
Pr_target_dBm = Pt_dBm + Gt_dBi + Gr_dBi - FSPL_target_dB - L_glass_total_dB - L_margin_dB;
SNR_target_dB = Pr_target_dBm - N_dBm;

d_max_SF7_m = interp1(SNR_dB, d_m, SNR_req_SF7);
d_max_SF10_m = interp1(SNR_dB, d_m, SNR_req_SF10);
d_max_SF12_m = interp1(SNR_dB, d_m, SNR_req_SF12);

fprintf('Distance: %.1f m\n', d_target_m);
fprintf('FSPL: %.2f dB\n', FSPL_target_dB);
fprintf('Glass loss %.2f dB\n', N_glass_panes, L_glass_total_dB);
fprintf('Margin (cable/impl/pol/multipath): %.2f dB\n', L_margin_dB);
fprintf('Received power Pr: %.2f dBm\n', Pr_target_dBm);
fprintf('Noise floor N: %.2f dBm\n', N_dBm);
fprintf('SNR: %.2f dB\n', SNR_target_dB);
fprintf('Max distance for SF7 (%.1f dB req): %.1f m\n', SNR_req_SF7, d_max_SF7_m);
fprintf('Max distance for SF10 (%.1f dB req): %.1f m\n', SNR_req_SF10, d_max_SF10_m);
fprintf('Max distance for SF12 (%.1f dB req): %.1f m\n', SNR_req_SF12, d_max_SF12_m);