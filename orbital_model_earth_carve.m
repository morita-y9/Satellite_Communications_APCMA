clear;
clc;
close all;
c  = 3e8;
GM = 3.986e14;
Re = 6.371e6;
fc = 920e6;
h  = 540e3;
El_min = 10;
v_sat = sqrt(GM/(Re+h));
w_sat = v_sat/(Re+h);
t = -300:0.1:300;
Emax_list = [30 50 70 90];
colors = lines(length(Emax_list));
figure;
for i = 1:length(Emax_list)
    Emax = Emax_list(i)*pi/180;
    dmin = Re*(sqrt(((Re+h)/Re)^2 - cos(Emax)^2) - sin(Emax));
    psi_min = acos((Re^2+(Re+h)^2-dmin^2)/(2*Re*(Re+h)));
    alpha = w_sat .* t;

    psi = acos(cos(psi_min).*cos(alpha));
    d = sqrt(Re^2+(Re+h)^2-2*Re*(Re+h).*cos(psi));
    El = asin(((Re+h)^2-Re^2-d.^2)./(2*Re.*d)) * 180/pi;

    ddot = Re*(Re+h)*cos(psi_min).*sin(alpha).*w_sat ./ d;
    fd = -(fc/c) .* ddot;
    dfd_dt = gradient(fd, t);
    tau = d / c;

    visible = El >= El_min;
    Tvis = t(visible);
    subplot(3,1,1); hold on;
    plot(t(visible), El(visible), 'Color', colors(i,:), 'LineWidth', 1.5);
    subplot(3,1,2); hold on;
    plot(t(visible), fd(visible)/1e3, 'Color', colors(i,:), 'LineWidth', 1.5);
    subplot(3,1,3); hold on;
    plot(t(visible), abs(dfd_dt(visible)), 'Color', colors(i,:), 'LineWidth', 1.5);
    fprintf('Emax=%2d deg  Tvis=%.2f min  fd_max=%.2f kHz  rate_max=%.1f Hz/s\n', ...
        Emax_list(i), (Tvis(end)-Tvis(1))/60, max(abs(fd(visible)))/1e3, max(abs(dfd_dt(visible))));
    tau_all{i} = tau(visible);
    El_all{i}  = El(visible);
    t_all{i}   = Tvis;
end

subplot(3,1,1);
yline(El_min,'--k'); grid on;
xlabel('time [s]'); ylabel('elevation [deg]');
title('Elevation Angle');
legend("Emax="+string(Emax_list)+"deg", 'Location','best');
subplot(3,1,2);
yline(0,'--k'); grid on;
xlabel('time [s]'); ylabel('Doppler [kHz]');
title('Doppler Shift (curved Earth)');
subplot(3,1,3);
grid on;
xlabel('time [s]'); ylabel('Doppler rate [Hz/s]');
title('Doppler Rate (curved Earth)');

figure;
subplot(2,1,1); hold on;
for i = 1:length(Emax_list)
    plot(t_all{i}, El_all{i}, 'Color', colors(i,:), 'LineWidth', 1.5);
end
yline(El_min,'--k'); grid on;
xlabel('time [s]'); ylabel('elevation [deg]');
title('Elevation Angle');
legend("Emax="+string(Emax_list)+"deg", 'Location','best');

subplot(2,1,2); hold on;
for i = 1:length(Emax_list)
    plot(t_all{i}, (tau_all{i} - min(tau_all{i}))*1e3, 'Color', colors(i,:), 'LineWidth', 1.5);
end
grid on;
xlabel('time [s]'); ylabel('latency [ms]');
title('Change in Propagation Delay (curved Earth)');
legend("Emax="+string(Emax_list)+"deg", 'Location','best');