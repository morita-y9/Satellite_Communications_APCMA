clear; 
clc;
close all;
% 定数
c   = 3e8;          
GM  = 3.986e14;     
Re  = 6.371e6;      
fc  = 920e6;        
h   = 540e3;       

% 衛星速度
v_sat = sqrt(GM / (Re + h));  

t = -450 : 0.1 : 450;  

% 斜距離
r  = sqrt(h^2 + (v_sat .* t).^2);  
% 仰角[rad]
El = atan2(h, abs(v_sat .* t));         

% 最低仰角以上に絞る（10度以上を可視とする）
El_min = 10 * pi/180;
visible = El >= El_min;

% Doppler・遅延
dr_dt = (v_sat^2 .* t) ./ r;           
fd    = -(fc / c) .* dr_dt;
dfd_dt = -(fc / c) .* (v_sat^2 ./ r - v_sat^4 .* t.^2 ./ r.^3);
tau   = r/c;                          

t_vis   = t(visible);
fd_vis  = fd(visible);
tau_vis = tau(visible);
El_vis  = El(visible) * 180/pi;
dfd_dt_vis = dfd_dt(visible);



%plot

figure;
subplot(3,1,1);
plot(t_vis, El_vis, 'g', 'LineWidth', 1.5);
yline(10, '--k'); grid on;
xlabel('time [s]'); ylabel('elevation angle [deg]');
title('Elevation Angle');

subplot(3,1,2);
plot(t_vis, fd_vis/1e3, 'b', 'LineWidth', 1.5);
yline(0, '--k'); grid on;
xlabel('time [s]'); ylabel('Doppler [kHz]');
title('Doppler Shift');

subplot(3,1,3);
plot(t_vis, abs(dfd_dt_vis), 'm', 'LineWidth', 1.5);
yline(0, '--k'); grid on;
xlabel('time [s]'); ylabel('Doppler rate [Hz/s]');
title('Doppler Rate');

figure;
subplot(2,1,1);
plot(t_vis, El_vis, 'g', 'LineWidth', 1.5);
yline(10, '--k'); grid on;
xlabel('time [s]'); ylabel('elevation angle [deg]');
title('Elevation Angle');

subplot(2,1,2);
plot(t_vis, (tau_vis - min(tau_vis))*1e3, 'r', 'LineWidth', 1.5);
grid on;
xlabel('time [s]'); ylabel('latency [ms]');
title('Change in Propagation Delay');

fprintf('Satellite Speed         : %.1f km/s\n', v_sat/1e3);
fprintf('Maximum Doppler Shift   : ±%.1f kHz\n', max(abs(fd_vis))/1e3);
fprintf('Delay Variation Range   : %.2f ms\n', (max(tau_vis)-min(tau_vis))*1e3);
fprintf('Visibility Duration     : %.1f min\n', (t_vis(end)-t_vis(1))/60);
