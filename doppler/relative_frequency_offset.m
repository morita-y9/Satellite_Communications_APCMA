clear;
clc;
close all;

h       = 540e3;
v_sat   = 7600;
f_c     = 920e6;
c_light = 3e8;
El_min  = 10;
BW      = 100e3;
SF      = 12;
n_bit   = 10;

M  = 2^SF;
df = BW / M;
T_slot = M / BW;

t_max = h / (v_sat * tand(El_min));
fd      = @(t) -(f_c/c_light) .* v_sat^2 .* t ./ sqrt(h^2 + (v_sat.*t).^2);
El_of_t = @(t) atand(h ./ abs(v_sat .* t));

El_range = linspace(El_min, 90, 200);

abs_shift_vs_El = (f_c/c_light) .* v_sat .* cosd(El_range) / df;

C    = 3 * 2^n_bit + 303;
T_cw = (C - 1) * T_slot;
pulse_slots = round(linspace(0, C-1, 9));
t_starts    = linspace(-t_max, t_max - T_cw, 300);

rel_drift = zeros(1, length(t_starts));
for k = 1:length(t_starts)
    t_p          = t_starts(k) + pulse_slots * T_slot;
    bins         = round(fd(t_p) / df);
    rel_drift(k) = max(bins) - min(bins);
end
El_centers = El_of_t(t_starts + T_cw/2);

figure('Position', [100 100 1000 400]);

subplot(1,2,1);
plot(El_range, abs_shift_vs_El, 'b-', 'LineWidth', 1.5);
grid on;
set(gca, 'FontSize', 24);
xlim([El_min, 90]);
xlabel('elevation angle [deg]');
ylabel('absolute bin shift [bins]');
title(sprintf('Absolute Bin Shift vs Elevation Angle (SF=%d)', SF));

subplot(1,2,2);
plot(El_centers, rel_drift, 'r-', 'LineWidth', 1.5);
grid on;
set(gca, 'FontSize', 24);
xlim([El_min, 90]);
xlabel('elevation angle at message center [deg]');
ylabel('relative bin drift [bins]');
title(sprintf('Relative Bin Drift vs Elevation Angle (SF=%d)', SF));