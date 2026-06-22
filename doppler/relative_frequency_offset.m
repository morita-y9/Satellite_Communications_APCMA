clear; 
close all; 
clc;

SF_list = [7, 8, 9, 10, 11, 12];
n_bit   = 8;
h       = 540e3;
v_sat   = 7600;
f_c     = 920e6;
c_light = 3e8;
El_min  = 10;
BW      = 100e3;

t_max = h / (v_sat * tand(El_min));
fd    = @(t) -(f_c/c_light) .* v_sat^2 .* t ./ sqrt(h^2 + (v_sat.*t).^2);
El_of_t = @(t) atand(h ./ abs(v_sat .* t));

rel_drift_vs_SF = zeros(1, length(SF_list));
rel_drift_vs_El = cell(1, length(SF_list));
El_starts_cell  = cell(1, length(SF_list));

for si = 1:length(SF_list)
    sf  = SF_list(si);
    M   = 2^sf;
    df  = BW / M;
    T_slot = M / BW;
    C   = 3 * 2^n_bit + 303;
    T_cw = (C - 1) * T_slot;

    pulse_slots = round(linspace(0, C-1, 9));
    t_starts    = linspace(-t_max, t_max - T_cw, 300);

    req_jt = zeros(1, length(t_starts));
    for k = 1:length(t_starts)
        t_p       = t_starts(k) + pulse_slots * T_slot;
        bins      = round(fd(t_p) / df);
        req_jt(k) = max(bins) - min(bins);
    end

    rel_drift_vs_SF(si) = max(req_jt);
    rel_drift_vs_El{si} = req_jt;
    El_starts_cell{si}  = El_of_t(t_starts + T_cw/2);
end

figure('Position', [100 100 1000 400]);

subplot(1,2,1);
plot(SF_list, rel_drift_vs_SF, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 8);
grid on;
xlabel('SF');
ylabel('max relative bin drift [bins]');
title('Relative Bin Drift vs SF');

subplot(1,2,2);
hold on;
colors = lines(length(SF_list));
for si = 1:length(SF_list)
    plot(El_starts_cell{si}, rel_drift_vs_El{si}, 'LineWidth', 1.5, 'Color', colors(si,:));
end
grid on;
xlabel('elevation angle at message center [deg]');
ylabel('relative bin drift [bins]');
title('Relative Bin Drift vs Elevation Angle');
legend("SF="+string(SF_list), 'Location', 'best');