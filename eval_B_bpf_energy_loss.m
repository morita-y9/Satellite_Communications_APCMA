clear; 
close all; 
clc;

SF = 12;
M  = 2^SF;
BW = 100e3;
Fs = BW;
df = BW / M;

v_sat   = 7600;
f_c     = 920e6;
c = 3e8;
fd_max  = (v_sat / c) * f_c;

n  = (0:M-1)';
up = exp(1j * pi * n.^2 / M);
dn = conj(up);

fd_vals = linspace(0, fd_max, 400);
peak_pw = zeros(1, 400);

for k = 1:400
    fd = fd_vals(k);
    rx = up .* exp(1j * 2*pi * (fd/Fs) * n);
    n_valid = max(0, floor(M * (1 - fd/BW)));
    rx(n_valid+1:end) = 0;
    pw = abs(fft(rx .* dn)).^2;
    peak_pw(k) = max(pw);
end

loss_sim  = 10 * log10(peak_pw / peak_pw(1));
loss_theo = 20 * log10(1 - fd_vals / BW);

elev      = linspace(0, 90, 300);
fd_elev   = (v_sat / c) * f_c * cosd(elev);
loss_elev = 20 * log10(1 - fd_elev / BW);

figure('Position', [100 100 900 400]);

subplot(1,2,1);
plot(fd_vals/1e3, loss_sim,  'b-',  'LineWidth', 2); hold on;
plot(fd_vals/1e3, loss_theo, 'r--', 'LineWidth', 1.5);
xlabel('Doppler Shift f_d [kHz]');
ylabel('Peak Power Loss [dB]');
title('Eval B: BPF Energy Loss vs Doppler Shift');
legend('Simulation', 'Theory: 20log_{10}(1-f_d/BW)', 'Location', 'southwest');
grid on;

subplot(1,2,2);
plot(elev, loss_elev, 'g-', 'LineWidth', 2);
set(gca, 'XDir', 'reverse');
xlabel('Elevation Angle [deg]');
ylabel('Peak Power Loss [dB]');
title('Eval B: BPF Energy Loss vs Elevation Angle');
grid on;
