clear; close all; clc;

SF     = 12;
M      = 2^SF;
BW     = 100e3;
df     = BW / M;
T_slot = M / BW;

n_bit  = 10;
C      = 3 * 2^n_bit + 303;
T_cw   = (C - 1) * T_slot;

h       = 540e3;
v_sat   = 7600;
f_c     = 920e6;
c_light = 3e8;
El_min  = 10;

fd    = @(t) -(f_c/c_light) .* v_sat^2 .* t ./ sqrt(h^2 + (v_sat.*t).^2);
t_max = h / (v_sat * tand(El_min));

fprintf('C = %d slots\n', C);
fprintf('T_cw = %.1f s\n', T_cw);
fprintf('T_pass = %.1f s\n', 2*t_max);

pulse_slots = round(linspace(0, C-1, 9));

t_starts = linspace(-t_max, t_max - T_cw, 300);

req_jt = zeros(1, length(t_starts));
for k = 1:length(t_starts)
    t_p       = t_starts(k) + pulse_slots * T_slot;
    bins      = round(fd(t_p) / df);
    req_jt(k) = max(bins) - min(bins);
end

fprintf('Max required JT = %d bins\n', max(req_jt));

t_pass = linspace(-t_max, t_max, 500);

figure('Position', [100 100 1000 400]);

subplot(1,2,1);
plot(t_pass, fd(t_pass)/1e3, 'b-', 'LineWidth', 1.5);
xlabel('time [s]');
ylabel('Doppler shift [kHz]');
title('Doppler profile (h=540km)');
grid on;

subplot(1,2,2);
plot(t_starts, req_jt, 'r-', 'LineWidth', 1.5); hold on;
yline(3, 'k--');
xlabel('TX start time [s]');
ylabel('jitter torelance [bins]');
title(sprintf('Eval C: Required JT  (SF=%d, n=%d, C=%d)', SF, n_bit, C));
grid on;