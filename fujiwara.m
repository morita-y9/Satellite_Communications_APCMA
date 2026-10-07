clear; close all;

% Parameters
BW = 100e3; SF = 12; Np = 5; W = 240;
Ts = 2^SF / BW;
CY = floor(W / Ts);
T  = 25.25 * Ts;
bits = [6 8 10];
N = 0.1:0.1:300;

figure;
subplot(1,2,1); hold on; grid on;
plot(N, ones(size(N)), 'LineWidth', 2, 'DisplayName', 'APCMA (all bits)');
plot(N, exp(-2*N*T/W), '--', 'LineWidth', 2, 'DisplayName', 'LoRa (pure ALOHA)');
xlabel('Number of nodes N'); ylabel('Reception rate');
title('Reception rate'); legend('Location', 'southwest'); ylim([0 1.05]);

subplot(1,2,2); hold on; grid on;
for k = 1:length(bits)
    Nc = 2^bits(k);
    C  = 3*2^bits(k) + 5;                      % codeword length [slot]
    b  = 1 - (1 - Np/CY).^N;
    ga = N .* (Nc-1) .* b.^3;                  % ghosts at true message positions
    gb = max(CY-C+1-N, 0) .* Nc .* b.^5;       % ghosts at other positions
    MR = (ga + gb) ./ (N + ga + gb);
    plot(N, MR, 'LineWidth', 2, 'DisplayName', sprintf('APCMA %d bit', bits(k)));
    n20 = N(find(MR >= 0.2, 1));
    fprintf('APCMA %2d bit: MR=20%% at %.1f nodes (LoRa RR = %.2f)\n', bits(k), n20, exp(-2*n20*T/W));
end
yline(0.2, ':', '20%', 'HandleVisibility', 'off');
xlabel('Number of nodes N'); ylabel('Misdetection rate');
title('Misdetection rate (APCMA)'); legend('Location', 'northwest'); ylim([0 0.6]);