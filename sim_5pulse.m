clear; 
close all; 
clc;

%% Parameters
SF      = 12;
n_bit   = 4;
BW      = 100e3;
h       = 540e3;
v_sat   = 7600;
f_c     = 920e6;
c_light = 3e8;
El_min  = 10;
snr_dB  = 0;
thr     = 0.5;
sim_num = 50;
N_list  = [10 30 50 70 100 150 200];

%% Derived parameters
M  = 2^SF;
Nm = 2^n_bit;
mpi = 0;
mid_pulse_vec = [15, 18, 25, 29, 26, 24, 22, 16, 13, 17, 14, 11, 8, 12, 4, 2];
L  = 3 * Nm + 5 + 4 * mpi;
Ns = L + 20;
s2 = 10^(-snr_dB / 10);

%% Chirp templates
n  = (0:M-1).';
up = exp(1j * pi * n.^2 / M);
dn = conj(up);

%% Codeword table
cw = make_5pulse_codeword(Nm, mpi, mid_pulse_vec, L);

%% Results
RR_arr    = zeros(size(N_list));
ghost_arr = zeros(size(N_list));

%% Main loop
for ni = 1:length(N_list)
    Nd = N_list(ni);
    rr_count    = 0;
    ghost_count = 0;

    for tr = 1:sim_num
        % Per-device random parameters
        El    = El_min + (90 - El_min) * rand(Nd, 1);
        d_i   = h ./ sind(El);
        fd_i  = (f_c / c_light) * v_sat * cosd(El);
        tau_i = d_i / c_light;
        msg_i = randi(Nm, Nd, 1);
        t0_i  = randi([0, Ns - L], Nd, 1);

        % Initialize received signal with AWGN
        rx = sqrt(s2 / 2) * (randn(Ns * M, 1) + 1j * randn(Ns * M, 1));

        % Add each device's signal
        for u = 1:Nd
            tau_samp = round(tau_i(u) * BW);
            pulse    = up .* exp(1j * 2 * pi * fd_i(u) / BW * n);
            ps       = t0_i(u) + cw(msg_i(u), :);

            for p = 1:5
                start_idx = ps(p) * M + tau_samp + 1;
                idx = start_idx : start_idx + M - 1;
                idx = idx(idx >= 1 & idx <= Ns * M);
                if length(idx) == M
                    rx(idx) = rx(idx) + pulse;
                end
            end
        end

        % Dechirp + FFT + threshold
        DFT_peaks = max(abs(fft(reshape(rx, M, Ns) .* dn)), [], 1) / M;
        dpos = find(DFT_peaks > thr) - 1;

        % Pattern matching
        decoded = zeros(0, 2);
        if ~isempty(dpos)
            for t0 = min(dpos) : max(dpos) - (L - 1)
                for x = 1:Nm
                    cand = sort(t0 + cw(x, :));
                    if all(ismember(cand, dpos))
                        decoded = [decoded; t0, x]; %#ok<AGROW>
                    end
                end
            end
        end

        % Reception rate
        for u = 1:Nd
            hit = any(decoded(:, 1) == t0_i(u) & decoded(:, 2) == msg_i(u));
            rr_count = rr_count + hit;
        end

        % Ghost count
        for d = 1:size(decoded, 1)
            is_real = any(t0_i == decoded(d, 1) & msg_i == decoded(d, 2));
            if ~is_real
                ghost_count = ghost_count + 1;
            end
        end
    end

    RR_arr(ni)    = rr_count / (Nd * sim_num);
    ghost_arr(ni) = ghost_count / sim_num;
end

%% Plot
figure('Position', [100 100 1000 400]);

subplot(1, 2, 1);
plot(N_list, RR_arr, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('number of devices');
ylabel('reception rate');
title('Reception Rate vs Number of Devices');
grid on;

subplot(1, 2, 2);
plot(N_list, ghost_arr, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('number of devices');
ylabel('average ghost count per trial');
title('Ghost Count vs Number of Devices');
grid on;

%% Codeword table (C++ aligned)
function cw = make_5pulse_codeword(Nm, mpi, mid_pulse_vec, L)
    cw = zeros(Nm, 5);
    for x = 1:Nm
        cw(x, :) = [ ...
            0, ...
            x + 1 + mpi, ...
            x + 2 + mpi + mid_pulse_vec(x) + mpi, ...
            L - (mpi + x + 2), ...
            L - 1];
    end
end