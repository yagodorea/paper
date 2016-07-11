function v = eeg_spectrum(signal, fs, tb, te)
% X_mags = abs(fft(signal));
% bin_vals = [0 : N-1];
% fax_Hz = bin_vals*fs/N;
% N_2 = ceil(N/2);
% plot(fax_Hz(1:N_2), X_mags(1:N_2))
% xlabel('Frequency (Hz)')
% ylabel('Magnitude');
% title('Single-sided Magnitude spectrum (Hertz)');
% axis tight
ts = te-tb;
n = ts*fs;

[B, A] = butter(3, [1 30]/(fs/2), 'bandpass');
signal = filtfilt(B, A, signal);
wo = 50/(fs/2);  bw = wo/35;
[B,A] = iirnotch(wo,bw);
signal = filtfilt(B, A, signal);

%data = data(:,1:n);x
data = signal(:,1+tb*fs:te*fs);
data = data - mean(data);


data = hanning(n)'.*data;
data=data/norm(data,Inf);


t = ts*[1:n]/n;

p = abs(fft(data,n));
p = fftshift(p);
%p = p.*conj(p)/n;
f = [-n/2:n/2-1]/n*fs;

%p=p.*conj(p)/n;


%semilogy(f,p);
%p = abs(fft(data))/(n/2);
%p = p(1:n/2).^2;
%freq = [0:n/2-1]/ts;
%plot(freq,p);

%plot(f,p);

figure

 subplot(2,1,1)
plot(t,signal(:,1+tb*fs:te*fs)/norm(signal(:,1+tb*fs:te*fs),Inf));
% 
% subplot(2,1,2)
% plot(t,data);
%xlim([0 0.5])
xlabel('Time(s)')
ylabel('Magnitude');

%figure

p = p.*conj(p)/n;

subplot(2,1,2)
plot(f,p)
xlim([0 60])
%ylim([0 2*10^8])
xlabel('Frequency (Hz)')
ylabel('Magnitude');
set(gca, 'FontSize', 12)

% subplot(2,2,4)
% semilogy(f,p);
% xlim([0 60])
end