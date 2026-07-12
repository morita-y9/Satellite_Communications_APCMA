clear; clc;

El_start_deg = 5;
approaching  = true;

c_light = 3e8; GM = 3.986e14; Re = 6.371e6; fc = 920e6; h = 540e3;
BW = 100e3; SF = 7; n_bit = 4;
v_sat = sqrt(GM/(Re+h)); w_sat = v_sat/(Re+h);
M = 2^SF; T_slot = M/BW; C = 3*2^n_bit+303;

d_f  = @(t) sqrt(Re^2+(Re+h)^2-2*Re*(Re+h)*cos(w_sat*t));
El_f = @(t) asin(((Re+h)^2-Re^2-d_f(t).^2)./(2*Re.*d_f(t)))*180/pi;
fd_f = @(t) -(fc/c_light).*Re.*(Re+h).*sin(w_sat.*t).*w_sat./d_f(t);

if approaching, t_s = linspace(-500,0,500000);
else,           t_s = linspace(0,500,500000); end
[~,idx] = min(abs(El_f(t_s)-El_start_deg));
t0 = t_s(idx);

ps  = round(linspace(0,C-1,5));
tp  = t0 + ps*T_slot;
fdp = fd_f(tp);
Elp = El_f(tp);

fprintf('%-8s %-10s %-12s %-12s\n','Pulse','t[s]','El[deg]','fd[Hz]');
for i=1:5, fprintf('P%-7d %-10.2f %-12.2f %-12.1f\n',i,tp(i),Elp(i),fdp(i)); end
fprintf('\nfloat fd_per_pulse[5] = {');
for i=1:5
    if i<5, fprintf('%.2ff, ',fdp(i)); else, fprintf('%.2ff',fdp(i)); end
end
fprintf('};\n');

t_pass = linspace(-300,300,50000);
vis = El_f(t_pass)>=10;
fig = figure('Visible','off');
subplot(2,1,1);
plot(t_pass(vis),El_f(t_pass(vis)),'b-','LineWidth',1.5); hold on;
scatter(tp,Elp,80,'r','filled');
for i=1:5, text(tp(i),Elp(i)+2,sprintf('P%d',i),'Color','r','HorizontalAlignment','center'); end
xlabel('time [s]'); ylabel('elevation [deg]'); grid on;
subplot(2,1,2);
plot(t_pass(vis),fd_f(t_pass(vis))/1e3,'b-','LineWidth',1.5); hold on;
scatter(tp,fdp/1e3,80,'r','filled');
for i=1:5, text(tp(i),fdp(i)/1e3+0.5,sprintf('P%d\n%.0fHz',i,fdp(i)),'FontSize',9,'Color','r','HorizontalAlignment','center'); end
xlabel('time [s]'); ylabel('Doppler [kHz]'); grid on;
saveas(fig,sprintf('doppler_per_pulse_el%d.png',round(El_start_deg)));