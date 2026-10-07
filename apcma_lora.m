clear; close all;

% Parameters
BW = 100e3; SF = 12; Np = 5; W = 240;
Ts = 2^SF / BW;            % slot length [s]
CY = floor(W / Ts);        % slots in visible time
T  = 25.25 * Ts;           % LoRa packet length [s]
bits = [6 8 10];
N = 1:300;

figure; hold on; grid on;
for k = 1:length(bits)
    Nc = 2^bits(k);
    b  = 1 - (1 - Np/CY).^N;
    ps = (1 - b.^(Np-2)).^(Nc-1);           % APCMA (Leibnitz et al.)
    plot(N, ps, 'LineWidth', 2, 'DisplayName', sprintf('APCMA %d bit', bits(k)));
    bt = (1 - 0.95^(1/(Nc-1)))^(1/(Np-2));
    fprintf('APCMA %2d bit: %.1f nodes\n', bits(k), log(1-bt)/log(1-Np/CY));
end
plot(N, exp(-2*N*T/W), '--', 'LineWidth', 2, 'DisplayName', 'LoRa (pure ALOHA)');
fprintf('LoRa       : %.1f nodes\n', -log(0.95)*W/(2*T));

yline(0.95, ':', '95%', 'HandleVisibility', 'off');
xlabel('Number of nodes N');
ylabel('Success probability');
title('APCMA vs LoRa (SF12, 1 channel, visible time 240 s)');
legend('Location', 'northeast');
ylim([0 1.02]);