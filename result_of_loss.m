clear; clc; close all;

font_size = 14;

att  = [20, 30, 40, 50, 60, 70, 75, 80];
rate = [100, 100, 100, 100, 100, 100, 90, 0];

figure;
plot(att, rate, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('Attenuation [dB]', 'FontSize', font_size);
ylabel('Demodulation Rate [%]', 'FontSize', font_size);
ylim([0 110]);
grid on;
set(gca, 'FontSize', font_size);