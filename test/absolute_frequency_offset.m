clear; clc; close all;

h       = 540e3;
v_sat   = 7600;
f_c     = 920e6;
c_light = 3e8;
El_min  = 10;

BW = 100e3;
t_max = h / (v_sat * tand(El_min));
fd    = @(t) -(f_c/c_light) .* v_sat^2 .* t ./ sqrt(h^2 + (v_sat.*t).^2);

SF_list = 7:12;
El_range = linspace(El_min, 90, 200);

colors = lines(length(SF_list));

figure('Position', [100 100 1000 400]);

subplot(1,2,1);
abs_shift = zeros(1, length(SF_list));
for si = 1:length(SF_list)
    M  = 2^SF_list(si);
    df = BW / M;
    abs_shift(si) = max(abs(fd(t_max)), abs(fd(-t_max))) / df;
end
plot(SF_list, abs_shift, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 8);
grid on;
xlabel('SF');
ylabel('max absolute bin shift [bins]');
title('Absolute Bin Shift vs SF');

subplot(1,2,2);
hold on;
for si = 1:length(SF_list)
    M  = 2^SF_list(si);
    df = BW / M;
    shift_vs_El = (f_c/c_light) .* v_sat .* cosd(El_range) / df;
    plot(El_range, shift_vs_El, 'LineWidth', 1.5, 'Color', colors(si,:));
end
grid on;
xlim([El_min 90]);
xlabel('elevation angle [deg]');
ylabel('absolute bin shift [bins]');
title('Absolute Bin Shift vs Elevation Angle');
legend("SF="+string(SF_list), 'Location', 'best');