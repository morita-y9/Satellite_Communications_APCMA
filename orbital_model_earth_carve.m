clear; clc; close all;

c   = 3e8;
GM  = 3.986e14;
Re  = 6.371e6;
fc  = 920e6;
h   = 540e3;

El_min = 10;
SF = 12;
n_bit = 10;
BW = 100e3;
M  = 2^SF;
T_slot = M / BW;
C = 3*2^n_bit + 303;
T_cw = (C-1)*T_slot;

v_sat = sqrt(GM / (Re + h));
w_sat = v_sat / (Re + h);

t = -300 : 0.01 : 300;
alpha = w_sat .* t;

d = sqrt(Re^2 + (Re+h)^2 - 2*Re*(Re+h).*cos(alpha));
El = asin(((Re+h)^2 - Re^2 - d.^2) ./ (2*Re.*d)) * 180/pi;
ddot = Re*(Re+h)*sin(alpha)*w_sat ./ d;
fd   = -(fc/c) .* ddot;
dfd_dt = gradient(fd, t);
tau  = d / c;

visible = El >= El_min;
El_vis     = El(visible);
fd_vis     = fd(visible);
dfd_dt_vis = dfd_dt(visible);
t_vis      = t(visible);
tau_vis    = tau(visible);

font_size = 24;

[El_sorted, idx_sort] = sort(El_vis);
fd_sorted     = fd_vis(idx_sort);
dfd_dt_sorted = dfd_dt_vis(idx_sort);

figure;
subplot(2,1,1);
plot(El_sorted, abs(fd_sorted)/1e3, 'b', 'LineWidth', 1.5);
grid on;
xlabel('elevation angle [deg]'); ylabel('|Doppler| [kHz]');
title('Doppler Shift');
set(gca, 'FontSize', font_size);

subplot(2,1,2);
plot(El_sorted, abs(dfd_dt_sorted), 'm', 'LineWidth', 1.5);
grid on;
xlabel('elevation angle [deg]'); ylabel('Doppler rate [Hz/s]');
title('Doppler Rate');
set(gca, 'FontSize', font_size);

figure;
plot(t_vis, (tau_vis - min(tau_vis))*1e3, 'r', 'LineWidth', 1.5);
grid on;
xlabel('time [s]'); ylabel('delay [ms]');
title('Propagation Delay');
set(gca, 'FontSize', font_size);

t_start = t_vis(t_vis + T_cw <= max(t_vis));
alpha_s = w_sat * t_start;
alpha_e = w_sat * (t_start + T_cw);
d_s = sqrt(Re^2 + (Re+h)^2 - 2*Re*(Re+h)*cos(alpha_s));
d_e = sqrt(Re^2 + (Re+h)^2 - 2*Re*(Re+h)*cos(alpha_e));
delay_change = abs(d_e - d_s) / c * 1e3;

fprintf('Satellite Speed         : %.1f km/s\n', v_sat/1e3);
fprintf('Maximum Doppler Shift   : ±%.1f kHz\n', max(abs(fd_vis))/1e3);
fprintf('Max Doppler Rate         : %.1f Hz/s\n', max(abs(dfd_dt_vis)));
fprintf('T_cw                     : %.1f s\n', T_cw);
fprintf('Max delay change within one codeword = %.3f ms\n', max(delay_change));