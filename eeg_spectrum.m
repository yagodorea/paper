function v = eeg_spectrum(signal, fs, tb, te)
% X_mags = abs(fft(signal));
% bin_vals = [0 : N-1];
% fax_Hz = bin_vals*fs/N;
% N_2 = ceil(N/2);
% plot(fax_Hz(1:N_2), X_mags(1:N_2))

ts = te-tb;
n = ts*fs;
data = signal(:,1+tb*fs:te*fs);
data = data - mean(data);

% Notch filter for 50Hz noise
wo = 50/(fs/2);  bw = wo/35;
[B,A] = iirnotch(wo,bw);
data = filter(B,A,data);

[B, A] = butter(3, [1 20]/(fs/2), 'bandpass');
data = filtfilt(B, A, data);

t = ts*(1:n)/n;
p = abs(fft(data,n));
p = fftshift(p);
f = (-n/2:n/2-1)/n*fs;

figure

subplot(2,2,1);
plot(t,data);

xlabel('Time(s)')
ylabel('Magnitude');
title('Raw sample');

% Applying Hanning window
data = hann(n)'.*data;

subplot(2,2,2)
plot(t,data);

xlabel('Time(s)')
ylabel('Magnitude');
title('Hanning window applied');

p = p.*conj(p)/n;
v = p((n/2+1):n);
subplot(2,2,[3,4])
plot(f,p)
xlim([0 60])

xlabel('Frequency (Hz)')
ylabel('Magnitude');
title('Single-sided Magnitude spectrum (Hertz)');

end