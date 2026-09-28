clear; clc; close all;
font_size = 60;

% dist_sf7  = [200 500 1200 2000 3000];
% PER_sf7   = [100 100 100 60 0];
% 
% dist_sf10 = [200 500 1200 2000 3000];
% PER_sf10  = [100 100 100 100 20];

dist_sf12 = [200 500 1200 2000 2450 2975];
PER_sf12  = [100 100 100 100 80 73];

figure;
% semilogx(dist_sf7,  PER_sf7,  '-o', 'LineWidth', 3, 'MarkerSize', 12, 'Color', [0.1 0.2 0.8]);
% hold on;
% semilogx(dist_sf10, PER_sf10, '-s', 'LineWidth', 3, 'MarkerSize', 12, 'Color', [0.85 0.3 0.1]);
plot(dist_sf12, PER_sf12, '-^', 'LineWidth', 3, 'MarkerSize', 12, 'Color', [0.1 0.5 0.1]);
grid on;
xlabel('distance [m]'); ylabel('demodulation rate [%]');
ylim([0 105]);
legend('SF=12', 'Location', 'southwest');
set(gca, 'FontSize', font_size);
hold off;