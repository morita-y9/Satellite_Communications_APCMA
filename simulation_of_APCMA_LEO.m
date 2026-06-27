clear;
close all; 
clc;

SF      = 12;
n_bit   = 4;
BW      = 100e3;
h       = 540e3;
v_sat   = 7600;
f_c     = 920e6;
c_light = 3e8;
El_min  = 10;

M      = 2^SF;
T_slot = M / BW;
C      = 3 * 2^n_bit + 303;

n  = (0:M-1).';
up = exp(1j * pi * n.^2 / M);
dn = conj(up);

Nm = 2^n_bit;
cw = zeros(Nm, 4);

for x = 1:Nm
    cw(x,:) = [0, x, C-x, C];
end

Ns = C + 20;

snr_dB = 0;
s2     = 10^(-snr_dB/10);
thr    = 0.5;

N_list = [10 30 50 70 100 150 200];
sim_num = 100;

RR_arr    = zeros(size(N_list));
ghost_arr = zeros(size(N_list));

for ni = 1:length(N_list)
    Nd = N_list(ni);
    rr_count    = 0;
    ghost_count = 0;

    for tr = 1:sim_num
        El    = El_min + (90 - El_min) * rand(Nd, 1);
        d_i   = h ./ sind(El);
        fd_i  = (f_c/c_light) * v_sat * cosd(El);
        tau_i = d_i / c_light;

        msg_i = randi(Nm, Nd, 1);
        t0_i  = randi(Ns - C - 1, Nd, 1) - 1;

        rx = sqrt(s2/2) * (randn(Ns*M, 1) + 1j*randn(Ns*M, 1));

        for u = 1:Nd
            tau_samp = round(tau_i(u) * BW);
            pulse    = up .* exp(1j * 2*pi * fd_i(u)/BW * n);
            ps       = t0_i(u) + cw(msg_i(u), :);

            for p = 1:4
                start_idx = ps(p)*M + tau_samp + 1;
                idx = start_idx : start_idx + M - 1;
                idx = idx(idx >= 1 & idx <= Ns*M);
                if length(idx) == M
                    rx(idx) = rx(idx) + pulse;
                end
            end
        end

        DFT_peaks = max(abs(fft(reshape(rx, M, Ns) .* dn)), [], 1) / M;
        det  = DFT_peaks > thr;
        dpos = find(det) - 1;

        decoded = zeros(0, 2);
        if ~isempty(dpos)
            for t0 = min(dpos) : max(dpos)-C
                for x = 1:Nm
                    cand = sort(t0 + cw(x,:));
                    if all(ismember(cand, dpos))
                        decoded = [decoded; t0, x];
                    end
                end
            end
        end

        for u = 1:Nd
            hit = any(decoded(:,1) == t0_i(u) & decoded(:,2) == msg_i(u));
            rr_count = rr_count + hit;
        end

        n_true_decoded = size(decoded, 1);
        ghost_count = ghost_count + max(0, n_true_decoded - Nd);
    end

    RR_arr(ni)    = rr_count / (Nd * sim_num);
    ghost_arr(ni) = ghost_count / sim_num;
end

figure('Position', [100 100 1000 400]);

subplot(1,2,1);
plot(N_list, RR_arr, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('number of devices');
ylabel('reception rate');
title('Reception Rate vs Number of Devices');
grid on;

subplot(1,2,2);
plot(N_list, ghost_arr, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('number of devices');
ylabel('average ghost count per trial');
title('Ghost Count vs Number of Devices');
grid on;
