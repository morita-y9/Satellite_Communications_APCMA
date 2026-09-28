clear; clc; close all;
font_size = 60;


SNR_sf7  = [-10 -9 -8 -7 -6 -5 -4 -3];
PER_sf7  = [0 10 24 65 94 98 99 100];

SNR_sf10 = [-19 -16 -15 -14 -13 -10 -5];
PER_sf10 = [0 13 75 99 100 100 100];

%修正前
SNR_sf12 = [-15 -14 -13 -12 -9 -4 0];
PER_sf12 = [0 0 23 83 95 100 100];

%修正後
%SNR_sf12 = [-21.4 -20.4 -19.4 -18.4 -15.4 -10];
%PER_sf12 = [0 17 52 100 100 100];


figure;
plot(SNR_sf7,  PER_sf7,  '-o', 'LineWidth', 3, 'MarkerSize', 12, 'Color', [0.1 0.2 0.8]);
hold on;
plot(SNR_sf10, PER_sf10, '-s', 'LineWidth', 3, 'MarkerSize', 12, 'Color', [0.85 0.3 0.1]);
plot(SNR_sf12, PER_sf12, '-^', 'LineWidth', 3, 'MarkerSize', 12, 'Color', [0.1 0.5 0.1]);
grid on;
xlabel('SNR [dB]'); ylabel('demodulation rate [%]');
ylim([0 105]);
legend('SF=7', 'SF=10', 'SF=12', 'Location', 'southeast');
set(gca, 'FontSize', font_size);
hold off;