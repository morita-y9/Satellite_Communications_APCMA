clear; close all; clc;

%ミクロ評価
%整数倍のビンがドップラーシフトによって小数部に来てしまう場合の電力低下
SF = 12;
N = 2^SF;
Fs = 100000;
BW = 100000;
df = Fs / N;
t = (0:N-1)/Fs;
mu = BW * Fs / N;
tx_chirp = exp(1i * pi * mu * t.^2);
rx_down_chirp = conj(tx_chirp);
fft_ideal = fft(tx_chirp .* rx_down_chirp);
ref_power = max(abs(fft_ideal).^2);
fd_bin_vec = 0:0.02:2;
max_power_dB = zeros(size(fd_bin_vec));
for idx = 1:length(fd_bin_vec)
    fd_bin = fd_bin_vec(idx);
    fd = fd_bin * df;
    rx_signal = tx_chirp .* exp(1i * 2 * pi * fd * t);
    dechirp_signal = rx_signal .* rx_down_chirp;
    fft_signal = fft(dechirp_signal);
    max_power = max(abs(fft_signal).^2);
    max_power_dB(idx) = 10 * log10(max_power / ref_power);
end

font_size = 16;

figure;
plot(fd_bin_vec, max_power_dB, 'LineWidth', 1.5);
grid on;
xlabel('Doppler Shift [bins]');
ylabel('Peak Power Loss[dB]');
title('Peak Power Loss due to Doppler Shift (micro)')
ylim([-5 1]);
set(gca, 'FontSize', font_size);