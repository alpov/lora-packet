datafile='rx46';

M=csvread(['d:\_lora\' datafile '.csv']);
lorafreqs=[867.1 867.3 867.5 867.7 867.9 868.1 868.3 868.5];
close all;

x=0;y=3;
for i=1:8
    figure(1); subplot('Position', [x*0.5+0.06 y*0.25+0.04 0.42 0.20]);
    lorahist(M(M(:,2)==lorafreqs(i),6), -125, -65, ['RSSI [dBm] for frequency ',num2str(lorafreqs(i)),' MHz'], 30);
    
    figure(2); subplot('Position', [x*0.5+0.06 y*0.25+0.04 0.42 0.20]);
    lorahist(M(M(:,2)==lorafreqs(i),5), -25, 15, ['SNR [dB] for frequency ',num2str(lorafreqs(i)),' MHz'], 30);
    
    x=x+1;
    if x>1
        x=0;
        y=y-1;
    end
end

figure(1); 
set(gcf, 'Position', [100 100 1200 1750]);
print('-dpng', [datafile '_rssi.png']);

figure(2); 
set(gcf, 'Position', [100 100 1200 1750]);
print('-dpng', [datafile '_snr.png']);

%%

figure(3);
set(gcf, 'Position', [100 100 1200 1350]);

x=0; y=2; subplot('Position', [x*0.5+0.06 y*0.33+0.04 0.42 0.28]);
lorahist(M(:,6), -125, -65, 'RSSI [dBm]', 30);

x=1; y=2; subplot('Position', [x*0.5+0.06 y*0.33+0.04 0.42 0.28]);
lorahist(M(:,5), -25, 15, 'SNR [dB]', 30);

x=0; y=1; subplot('Position', [x*0.5+0.06 y*0.33+0.04 0.42 0.28]);
Md = categorical(M(:,2), [867.1 867.3 867.5 867.7 867.9 868.1 868.3 868.5], {'867.1' '867.3' '867.5' '867.7' '867.9' '868.1' '868.3' '868.5'});
histogram(Md, 'BarWidth', 0.8); grid on;
xlabel('Frequency [MHz]');
ylabel('Packet count');

x=1; y=1; subplot('Position', [x*0.5+0.06 y*0.33+0.04 0.42 0.28]);
lorahist(M(:,7), 0, 255, 'Length [B]', 30);
xlabel('Data length [B]');
ylabel('Packet count');

x=0; y=0; subplot('Position', [x*0.5+0.06 y*0.33+0.04 0.42 0.28]);
Md = categorical(M(:,3), [7 8 9 10 11 12], {'SF7', 'SF8', 'SF9', 'SF10', 'SF11', 'SF12'});
histogram(Md, 'BarWidth', 0.8); grid on;
xlabel('Spreading factor');
ylabel('Packet count');

x=1; y=0; subplot('Position', [x*0.5+0.06 y*0.33+0.04 0.42 0.28]);
Md = categorical(M(:,4), [0 5 6 7 8], {'OFF', '4/5', '4/6', '4/7', '4/8'});
histogram(Md, 'BarWidth', 0.8); grid on;
xlabel('Code rate');
ylabel('Packet count');
print('-dpng', [datafile '.png']);

