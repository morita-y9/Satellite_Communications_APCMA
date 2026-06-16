clear; 
close all; 
clc;

SF_list = [7, 8, 9, 10, 11, 12];

n_bit  = 10;
h       = 540e3;
v_sat   = 7600;
f_c     = 920e6;
c_light = 3e8;
El_min  = 10;
t_max = h / (v_sat * tand(El_min));

SF     = 12;
M      = 2^SF;
BW     = 100e3;
df     = BW / M;
T_slot = M / BW;
C      = 3 * 2^n_bit + 303;
T_cw   = (C - 1) * T_slot;
fd     = @(t) -(f_c/c_light) .* v_sat^2 .* t ./ sqrt(h^2 + (v_sat.*t).^2);

fprintf('C = %d slots\n', C);
fprintf('T_cw = %.1f s\n', T_cw);
fprintf('T_pass = %.1f s\n', 2*t_max);

pulse_slots = round(linspace(0, C-1, 9));
t_starts    = linspace(-t_max, t_max - T_cw, 300);

req_jt = zeros(1, length(t_starts));
for k = 1:length(t_starts)
    t_p        = t_starts(k) + pulse_slots * T_slot;
    bins       = round(fd(t_p) / df);
    req_jt(k)  = max(bins) - min(bins);
end

fprintf('Max bin drift = %d bins\n', max(req_jt));

max_drift = zeros(1, length(SF_list));
for si = 1:length(SF_list)
    sf     = SF_list(si);
    m      = 2^sf;
    df_sf  = BW / m;
    ts     = m / BW;
    c      = 3 * 2^n_bit + 303;
    tcw    = (c - 1) * ts;
    ps     = round(linspace(0, c-1, 9));
    ts_vec = linspace(-t_max, t_max - tcw, 300);
    md     = 0;
    for k = 1:length(ts_vec)
        t_p  = ts_vec(k) + ps * ts;
        bins = round(fd(t_p) / df_sf);
        md   = max(md, max(bins) - min(bins));
    end
    max_drift(si) = md;
end

t_pass = linspace(-t_max, t_max, 500);

figure('Position', [100 100 1000 400]);

subplot(1,2,1);
plot(t_starts, req_jt, 'r-', 'LineWidth', 1.5);
xlabel('TX start time [s]');
ylabel('Max bin drift [bins]');
title(sprintf('Bin Drift (SF=12)'));
grid on;

subplot(1,2,2);
plot(SF_list, max_drift, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 8);
xlabel('SF');
ylabel('Max bin drift [bins]');
title('Max Bin Drift vs SF');
grid on;