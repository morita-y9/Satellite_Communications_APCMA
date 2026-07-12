clear; clc;

Pt_mW=20; Gt=1.0; Gr=6.5; NF=4.0; Pol_loss=3.0;

c=3e8; Re=6.371e6; fc=920e6; h=540e3;
k=1.380649e-23; T0=300; BW=100e3;
gamma_O2=0.007; h_atm=10;

Pt_dBm = 10*log10(Pt_mW);
N0     = 10*log10(k*T0*1000);
Nf     = N0 + 10*log10(BW) + NF;

El   = linspace(1,90,500);
d_km = (sqrt((Re+h)^2-(Re*cosd(El)).^2)-Re*sind(El))/1e3;
FSPL = 20*log10(4*pi*d_km*1e3/(c/fc));
Latm = gamma_O2*h_atm./sind(El);
Pr   = Pt_dBm+Gt+Gr-FSPL-Latm-Pol_loss;

SF_list = [7 9 10 11 12];
SNR_req = [-7.5 -12.5 -15 -17.5 -20];
Sens    = Nf + SNR_req;

idx10 = find(El>=10,1);
fprintf('%-5s %-10s %-12s %-12s\n','SF','Sens[dBm]','Margin@10','Margin@90');
for i=1:length(SF_list)
    fprintf('SF=%-3d %-10.2f %-12.2f %-12.2f\n', ...
        SF_list(i),Sens(i),Pr(idx10)-Sens(i),Pr(end)-Sens(i));
end

fig = figure('Visible','off');
colors = lines(length(SF_list));
hold on;
for i=1:length(SF_list)
    plot(El,Pr-Sens(i),'LineWidth',1.5,'Color',colors(i,:),'DisplayName',sprintf('SF=%d',SF_list(i)));
end
yline(0,'-k','LineWidth',1.5);
xline(10,'--','Color',[.5 .5 .5]);
grid on;
xlabel('elevation angle [deg]'); ylabel('link margin [dB]');
legend('Location','best');
saveas(fig,'link_budget_leo.png');