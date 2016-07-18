function real_time_spectrum()
close
clear

%start GPU processing 
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\NOTICE\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%\\\\\\\\\WILL NOT WORK WITHOUT COMPACTIBLE GPU DEVICE !\\\\\\\\\\\\\\\\\\
%\\\\\\\\\CHANGE CODE TO WORK WITH NORMAL ARRAYS AND REMOVE \\\\\\\\\\\\\\
%\\\\\\\\\GPU PROCESSING IF GPU IS UNAVAILABLE !\\\\\\\\\\\\\\\\\\\\\\\\\\

gpu = parallel.gpu.GPUDevice.getDevice(1);
d = gpuDevice();

comPort = 'COM3';

step = 100;

signal_tw = 1;
spec_tw = 10;

fs = 600;

count = 0;

% v = zeros(1,step+fs);
% i = 1;
% a = zeros(1,600*10);
% temp = zeros(1,600*10);

delete(instrfindall);
% Open serial connection with Arduino
s = serial(comPort);
set(s,'DataBits',8);
set(s,'StopBits',1);
set(s,'BaudRate',115200);
set(s,'Parity','none');
fclose(s);
fopen(s);

%signal = serialRead('COM3',10);
% while (i <=600*10)
%
%         a(1,1) = fread(s,1,'uint8');
%         a(1,2) = fread(s,1,'uint8');
%         b = a(1,1) + bitshift(a(1,2),8);
%         b = typecast(uint16(b),'int16');
%         v(1,i) = b;
%         i = i+1;
%         %fprintf('.');
%         %axis([1 500 0 60000]);
%         %plot(temp);
%         %drawnow
% end
signal = zeros(1,fs,'gpuArray');
spec = zeros(1000,600,'gpuArray');

%
% %[B, A] = butter(3, [1 30]/(fs/2), 'bandpass');
% %signal = filtfilt(B, A, signal);
% wo = 50/(fs/2);  bw = wo/35;
% [B,A] = iirnotch(wo,bw);
% signal = filter(B, A, signal);
% %data = signal(:,1+tb*fs:te*fs);
% %signal = signal - mean(signal);
% n = norm(signal,Inf);
% signal = signal/n;

%ps = animatedline;

figure(1)

subplot(2,1,1)
title('Signal')
ylabel('Amplitude')
xlabel('Time')

subplot(2,1,2)
title('Spectrum')
xlabel('Amplitude')
ylabel('Time')



dialogBox = uicontrol('Style', 'PushButton', 'String', 'Break','Callback', 'delete(gcbf)');
while (ishandle(dialogBox))
%while(1)
    
    
    
    %new_signal = serialRead('COM3',1);
    v = zeros(1,step);
    i = 1;
    a = zeros(1,step);
    temp = zeros(1,step);
    while (i <= step)
        
        a(1,1) = fread(s,1,'uint8');
        a(1,2) = fread(s,1,'uint8');
        b = a(1,1) + bitshift(a(1,2),8);
        b = typecast(uint16(b),'int16');
        v(1,i) = b;
        i = i+1;
        %fprintf('.');
        %axis([1 500 0 60000]);
        %plot(temp);
        %drawnow
    end
    
    new_signal=gpuArray(v*0.000125/17604);
    
    t = 0:1/fs:(step-1)/fs;
    t = t + count*step/fs;
    
    %[B, A] = butter(3, [1 30]/(fs/2), 'bandpass');
    %new_signal = filter(B, A, new_signal);
    wo = 50/(fs/2);  bw = wo/20;
    [B,A] = iirnotch(wo,bw);
    new_signal = filter(B, A, new_signal);
    %%data = signal(:,1+tb*fs:te*fs);
    %new_signal = new_signal - mean(new_signal);
    %new_signal = new_signal/n;
    conn_point = signal(:,fs);
    signal(:,1:fs-step) = signal(:,step+1:fs);
    signal(:,fs-step+1:fs) = new_signal;
    
    
    ts = spec_tw;
    n = fs;
    dn = fs-step;
    
    
    % t = 0:10000000;
    
    % for i = 1:steps
    
    data = signal;
    %data = test(1,count*step+1:fs+count*step);
    
    data = hanning(n)'.*data;
    %data=data/norm(data,Inf);
    
    %t = ts*[1:n]/n;
    
    p = abs(fft(data,[]));
    p = fftshift(p);
    p = p.*conj(p)/n;
    % p = p/norm(p,Inf);
    f = [-n/2:n/2-1]/n*fs;
    p = p/norm(p,Inf);
    spec(count+1,:) = p;
    
    %print on spectrum plot
    figure(1)
    subplot(2,1,2)
    if count > 0
        fig = pcolor( f,[(count-1)*step/fs ; (count)*step/fs], spec(count:count+1,:));
              
        set(fig, 'EdgeColor', 'none');
        view(-90,90)
        set(gca,'ydir','reverse')
        xlim([0 30])
        ylim ([(count+1)*step/fs-spec_tw (count+1)*step/fs] )
        %ylim([1 100])
        hold on
        
    end
    
    
    %print signal window
    figure(1)
    subplot(2,1,1)
    ps = plot([t(1,1)-1/fs t],[conn_point gather(new_signal)],'b')
   % addpoints(ps,t,gather(new_signal));
    xlim ([(count+1)*step/fs-signal_tw (count+1)*step/fs] )
    hold on
    
    
    
    % xlim([0 1])
    %subplot(2,1,2)
    % my_spectrogram(signal,600,0,10,600-step);
    % ylim([0 20])
    drawnow limitrate
    
    
    
    
    count = count+1;
end

end

