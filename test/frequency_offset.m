clear; clc; close all;

h       = 540e3;
v_sat   = 7600;
f_c     = 920e6;
c_light = 3e8;
El_min  = 10;
n_bit   = 8;
SF      = 12;

M      = 2^SF;
BW     = 100e3;
df     = BW / M;
T_slot = M / BW;
C      = 3 * 2^n_bit + 303;
T_cw   = (C - 1) * T_slot;

t_max = h / (v_sat * tand(El_min));
fd    = @(t) -(f_c/c_light) .* v_sat^2 .* t ./ sqrt(h^2 + (v_sat.*t).^2);

t_pass  = linspace(-t_max, t_max, 1000);
bin_abs = fd(t_pass) / df;

pulse_slots = round(linspace(0, C-1, 9));
t_starts    = linspace(-t_max, t_max - T_cw, 300);

bin_lo = zeros(1, length(t_starts));
bin_hi = zeros(1, length(t_starts));
for k = 1:length(t_starts)
    t_p       = t_starts(k) + pulse_slots * T_slot;
    bins      = round(fd(t_p) / df);
    bin_lo(k) = min(bins);
    bin_hi(k) = max(bins);
end
req_jt = bin_hi - bin_lo;

[max_abs, idx_abs] = max(abs(bin_abs));
[max_rel, idx_rel] = max(req_jt);

fprintf('Max absolute bin offset = %.0f bins  at t = %.1f s\n', max_abs, t_pass(idx_abs));
fprintf('Max relative bin drift  = %d bins  at t_start = %.1f s\n', max_rel, t_starts(idx_rel));
fprintf('Conservative sum (never co-occurs) = %.0f bins\n', max_abs + max_rel);

figure('Position', [100 100 1400 400]);

subplot(1,3,1);
plot(t_pass, bin_abs, 'b-', 'LineWidth', 1.5); hold on;
plot(t_pass(idx_abs), bin_abs(idx_abs), 'ko', 'MarkerFaceColor', 'k');
xlabel('time [s]');
ylabel('absolute bin offset');
title('Absolute Doppler Bin Offset');
grid on;

subplot(1,3,2);
plot(t_starts, req_jt, 'r-', 'LineWidth', 1.5); hold on;
plot(t_starts(idx_rel), req_jt(idx_rel), 'ko', 'MarkerFaceColor', 'k');
xlabel('TX start time [s]');
ylabel('relative bin drift [bins]');
title('Relative Bin Drift per Message');
grid on;

subplot(1,3,3);
fill([t_starts, fliplr(t_starts)], [bin_hi, fliplr(bin_lo)], ...
    [0.7 0.85 1], 'EdgeColor', 'none'); hold on;
plot(t_starts, bin_hi, 'b-', 'LineWidth', 1.2);
plot(t_starts, bin_lo, 'b-', 'LineWidth', 1.2);
xlabel('TX start time [s]');
ylabel('bin range');
title('Combined Bin Range per Message');
grid on;