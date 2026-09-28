clear; clc;

fsize = 24;

snr_sf7    = [-10 -9 -8 -7 -6 -5 -4 -3 0 1];
demod_sf7  = [0 10 24 65 94 98 99 100 100 100];

snr_sf10   = [-19 -17 -16 -15 -14 -13 -10 -5 0 1];
demod_sf10 = [0 13 75 99 100 100 100 100 100 100];

snr_sf12   = [-14 -13 -12 -9 -4 0 1];
demod_sf12 = [0 23 83 95 100 100 100];

figure; hold on; grid on;
plot(snr_sf7,  demod_sf7,  '-o', 'LineWidth', 1.5, 'MarkerSize', 8, 'DisplayName', 'SF7');
plot(snr_sf10, demod_sf10, '-s', 'LineWidth', 1.5, 'MarkerSize', 8, 'DisplayName', 'SF10');
plot(snr_sf12, demod_sf12, '-^', 'LineWidth', 1.5, 'MarkerSize', 8, 'DisplayName', 'SF12');

xlabel('SNR [dB]');
ylabel('Demodulation rate [%]');
legend('Location', 'southeast');
ylim([-5 105]);
set(gca, 'FontSize', fsize);