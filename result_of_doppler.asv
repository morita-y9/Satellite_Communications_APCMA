clear; clc; close all;

font_size = 2;

fd   = [0, 5, 10, 15, 20, 25, 30, 40, 50, 100, 150, 200];
rate = [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 90, 0];

fd_max_leo = 21.2;

figure;
plot(fd, rate, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6);
xline(fd_max_leo, '--r', 'LineWidth', 1.5, 'FontSize', font_size);
xlabel('Doppler Shift [kHz]', 'FontSize', font_size);
ylabel('Demodulation Rate [%]', 'FontSize', font_size);
grid on;
set(gca, 'FontSize', font_size);