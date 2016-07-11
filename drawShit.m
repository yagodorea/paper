function v = drawShit(data)

fs = 600;
f = (-fs/2:fs/2-1);

v = zeros(1,30);
subplot(1,1,1);

for i=1:30

    sec = data((600*(i-1))+1:600*i);
    
    % Notch filter for 50Hz noise
    wo = 50/(fs/2);  bw = wo/35;
    [B,A] = iirnotch(wo,bw);
    sec = filter(B,A,sec);

    % Band-pass filter
    [B, A] = butter(3, [1 20]/(fs/2), 'bandpass');
    sec = filtfilt(B, A, sec);
    
    sec = abs(fft(sec,600));
    sec = fftshift(sec);
    
    hold on
    plot(f,sec);
    ylim([1 30]);
    xlim([1 60]);
    drawnow
    
    cut = sec(301:600);
    cut(1) = 0;
    v(i) = find(cut == max(cut));
    pause(0.2);
end