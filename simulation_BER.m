clear; close all;

SF  = 12;  BW = 100e3;  M = 2^SF;
C   = 19;  Nm = 8;  Np = 4;
Ns  = C + 1;
Ntr = 300;
thr = 0.5;

f_c     = 920e6;
c_light = 3e8;
v_sat   = 7600;

cw = [zeros(Nm,1), (1:Nm).', (C-(1:Nm)).', C*ones(Nm,1)];

n  = (0:M-1).';
up = exp(1j * pi * n.^2 / M);
dn = conj(up);

snr_dB = -30:2:5;
El_test = [90 10];
PER = zeros(numel(El_test), numel(snr_dB));

for ei = 1:numel(El_test)
    fd = (f_c/c_light) * v_sat * cosd(El_test(ei));

    for si = 1:numel(snr_dB)
        s2 = 10^(-snr_dB(si)/10);
        ok_pkt = 0;

        for tr = 1:Ntr
            msg = randi(Nm);
            ps  = cw(msg,:) + 1;

            rx = sqrt(s2/2) * (randn(Ns*M,1) + 1j*randn(Ns*M,1));
            for p = 1:Np
                idx = (ps(p)-1)*M + (1:M).';
                rx(idx) = rx(idx) + up .* exp(1j*2*pi*fd/BW*n);
            end

            DFT_peaks = max(abs(fft(reshape(rx, M, Ns) .* dn)), [], 1) / M;
            det = DFT_peaks > thr;
            dpos = sort(find(det) - 1);

            for m = 1:Nm
                if numel(dpos) == Np && isequal(dpos(:), sort(cw(m,:).'))
                    ok_pkt = ok_pkt + (m == msg);
                    break;
                end
            end
        end
        PER(ei,si) = 1 - ok_pkt / Ntr;
    end
end

figure;
semilogy(snr_dB, PER(1,:)+1e-4, 'b-o', snr_dB, PER(2,:)+1e-4, 'r-o');
xlabel('SNR (dB)'); ylabel('PER');
title('PER vs SNR with Doppler (El=90 vs El=10)');
legend('El=90 (zenith)', 'El=10 (edge)', 'Location', 'southwest');
grid on; ylim([1e-3 1.1]);さ