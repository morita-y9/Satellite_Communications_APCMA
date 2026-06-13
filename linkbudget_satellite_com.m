%リンクバジェット計算
%今後、減衰、フェージング、マルチパス、干渉などを組み込む必要あり
clear;
close all;
clc;

%パラメータ(定数)
c = 3.0e8;
f = 9.2e8;
%距離パラメータ
d_GEO = 35786e3;
d_LEO = 380e3;
L = 20*log10(4*pi*d_LEO*f/c);
k = 1.38e-23;
lambda = c/f;
Gt = 1;
margin = 10;

%SFによるSNRしきい値(LoRaの標準値)
SF = 7:12;
SNR_th = [-7.5, -10.0, -12.5, -15.0, -17.5, -20.0];


%パラメータ(変数)
Gr = 0:50;
T = 300; %27℃を想定
B = 100e3; %帯域幅は100kHzまたは125kHz
Pt = 13;


%受信電力[dBm]
pr = Pt + Gt + Gr - L;

%ノイズ(ガウシアンノイズ)し
pn = 10*log10(k*T*B)+30;
SNR = pr - pn;


%plot
figure;
plot(Gr, SNR, 'LineWidth', 1.5, 'DisplayName', 'SNR');
hold on;

col = lines(6);
for i = 1:6
    yline(SNR_th(i), '-', 'Color', col(i,:), 'LineWidth', 1.2, ...
        'DisplayName', sprintf('SF%d %.1f dB', SF(i), SNR_th(i)));
end

hold off;
grid on;

xlim([0 50]);
ylim([-40 10]);
xlabel('受信アンテナ利得 Gr [dBi]', 'FontSize',12);
ylabel('SNR [dB]', 'FontSize',12);
title('受信アンテナ利得とSNRの関係','FontSize',14);
legend('Location', 'northwest', 'FontSize', 10);

%最小アンテナ利得
G_rx_min = SNR_th + margin - (Pt + Gt - L - pn);

G_rx_lin = 10.^(G_rx_min / 10);
%必要なアンテナの直径の計算
D_min = (lambda/pi) .*(sqrt(G_rx_lin/0.6)); %開口能率 η=0.6

%% ターミナル出力
fprintf('SF別 必要最低アンテナ利得（マージン %d dB込み）\n', margin);
fprintf('SF G_rx_min [dBi] ｌ D_min [m]\n');

for i = 1:6
    fprintf('SF%d %14.1f %9.2f\n', SF(i), G_rx_min(i), D_min(i));
end

