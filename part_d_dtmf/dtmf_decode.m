% Part D: DTMF Fourier Analysis
% Decode 4-digit PIN from DTMF audio signal
%
% DTMF Frequency Matrix:
%          1209Hz  1336Hz  1477Hz
%  697Hz     1       2       3
%  770Hz     4       5       6
%  852Hz     7       8       9
%  941Hz     *       0       #

clear; clc; close all;

%% Create output directory for figures
output_dir = '../output_figures';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% Step 1: Select WAV file based on student IDs
% Z = ceil(X + Y/2)
% X = last digit of Student ID 1
% Y = last digit of Student ID 2
X = 6;  % Last digit of Student ID 1
Y = 8;  % Last digit of Student ID 2

Z = ceil(X + Y/2);
% Map Z to file index (0-9), handle Z=10 -> pin_0
file_idx = mod(Z, 10);
filename = sprintf('pin_%d.wav', file_idx);

fprintf('Student ID 1 last digit: %d\n', X);
fprintf('Student ID 2 last digit: %d\n', Y);
fprintf('Z = ceil(%d + %d/2) = %d\n', X, Y, Z);
fprintf('File index: %d\n', file_idx);
fprintf('Loading file: %s\n\n', filename);

%% Step 2: Read audio file
[sig, fs] = audioread(filename);
sig = sig(:, 1);  % Use only first channel if stereo
Ns = length(sig);
T_total = Ns / fs;

fprintf('Audio File Info:\n');
fprintf('  Sampling frequency: %d Hz\n', fs);
fprintf('  Total samples: %d\n', Ns);
fprintf('  Duration: %.3f seconds\n\n', T_total);

%% Step 3: Analyze signal to determine tone parameters
figure('Name', 'Full Signal Analysis', 'Position', [100 100 1200 400]);

% Plot time domain
subplot(2,1,1);
t = (0:Ns-1)/fs;
plot(t, sig);
title('Complete DTMF Signal');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

% Plot envelope to detect tone boundaries
subplot(2,1,2);
window_size = round(fs * 0.01);  % 10ms window
envelope = movmean(abs(sig), window_size);
plot(t, envelope);
title('Signal Envelope (for tone detection)');
xlabel('Time (s)'); ylabel('Envelope');
grid on;
hold on;

% Threshold for detecting active tones
threshold = 0.1 * max(envelope);
plot(t, threshold * ones(size(t)), 'r--', 'LineWidth', 2);
legend('Envelope', 'Threshold');

%% Step 4: Detect tone segments
active = envelope > threshold;
% Find transitions
transitions = diff([0; active; 0]);
tone_start = find(transitions == 1);
tone_end = find(transitions == -1) - 1;

fprintf('Detected %d tone segments\n', length(tone_start));
for i = 1:length(tone_start)
    duration = (tone_end(i) - tone_start(i) + 1) / fs;
    fprintf('  Tone %d: Start=%.3fs, End=%.3fs, Duration=%.3fs\n', ...
        i, tone_start(i)/fs, tone_end(i)/fs, duration);
end
fprintf('\n');

%% Step 5: Parameters for FFT analysis
% Window selection: Hamming window (good for DTMF - reduces spectral leakage)
window_type = 'hamming';

% DTMF frequencies (for reference)
row_freqs = [697, 770, 852, 941];
col_freqs = [1209, 1336, 1477];
freq_tol = 20;  % Frequency tolerance: +/- 20 Hz

% Determine appropriate window size and parameters
% For DTMF, we need frequency resolution better than ~30Hz to separate tones
% Using N = 1024 samples at 8kHz gives ~7.8Hz resolution
N_fft = 1024;  

fprintf('FFT Analysis Parameters:\n');
fprintf('  Window type: %s\n', window_type);
fprintf('  FFT size: %d\n', N_fft);
fprintf('  Frequency resolution: %.2f Hz\n', fs/N_fft);
fprintf('  Frequency tolerance: +/- %d Hz\n\n', freq_tol);

%% Step 6: Analyze each tone and decode digits
figure('Name', 'DTMF Spectrum Analysis', 'Position', [100 550 1400 900]);

pin = [];
colormap_val = lines(4);

for i = 1:4
    subplot(4, 2, 2*i-1);
    
    % Extract tone segment with some padding for better analysis
    start_idx = tone_start(i);
    end_idx = tone_end(i);
    tone_sig = sig(start_idx:end_idx);
    
    % Apply window function
    if strcmp(window_type, 'hamming')
        win = hamming(length(tone_sig));
    elseif strcmp(window_type, 'hann')
        win = hann(length(tone_sig));
    else
        win = rectwin(length(tone_sig));
    end
    
    % Apply window and zero-pad to N_fft
    windowed_sig = tone_sig .* win;
    if length(windowed_sig) < N_fft
        windowed_sig = [windowed_sig; zeros(N_fft - length(windowed_sig), 1)];
    else
        windowed_sig = windowed_sig(1:N_fft);
    end
    
    % Compute FFT
    S = fft(windowed_sig);
    S_mag = abs(S(1:N_fft/2+1));
    f = (0:N_fft/2)*fs/N_fft;
    
    % Plot spectrum
    plot(f, 20*log10(S_mag + eps), 'LineWidth', 1);
    xlim([600 1600]);
    title(sprintf('Tone %d Spectrum (Sample: %d to %d)', i, start_idx, end_idx));
    xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
    grid on;
    hold on;
    
    % Mark DTMF frequencies
    for rf = row_freqs
        xline(rf, 'r--', 'Alpha', 0.5);
    end
    for cf = col_freqs
        xline(cf, 'g--', 'Alpha', 0.5);
    end
    
    % Find peaks
    [peaks, locs] = findpeaks(20*log10(S_mag + eps), f, ...
        'MinPeakHeight', max(20*log10(S_mag + eps)) - 20, ...
        'MinPeakDistance', 50);
    
    % Identify DTMF tones
    detected_row = 0;
    detected_col = 0;
    
    for p = 1:length(peaks)
        for r = 1:4
            if abs(locs(p) - row_freqs(r)) < freq_tol
                detected_row = r;
            end
        end
        for c = 1:3
            if abs(locs(p) - col_freqs(c)) < freq_tol
                detected_col = c;
            end
        end
    end
    
    % Decode digit
    dtmf_matrix = ['1', '2', '3'; '4', '5', '6'; '7', '8', '9'; '*', '0', '#'];
    if detected_row > 0 && detected_col > 0
        digit = dtmf_matrix(detected_row, detected_col);
        pin = [pin, digit];
        
        % Mark detected frequencies
        if detected_row > 0
            plot(row_freqs(detected_row), peaks(1), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        end
        if detected_col > 0
            plot(col_freqs(detected_col), peaks(end), 'go', 'MarkerSize', 10, 'LineWidth', 2);
        end
        
        title(sprintf('Tone %d Spectrum: Detected Digit = %c', i, digit));
    else
        title(sprintf('Tone %d: Detection Failed', i));
        pin = [pin, '?'];
    end
    
    % Time domain plot
    subplot(4, 2, 2*i);
    tone_t = (0:length(tone_sig)-1)/fs;
    plot(tone_t, tone_sig, 'Color', colormap_val(i, :));
    title(sprintf('Tone %d Time Domain', i));
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;
end

%% Step 7: Display results
fprintf('========================================\n');
fprintf('DECODED PIN: %s\n', pin);
fprintf('========================================\n\n');

fprintf('Tone Parameters Used:\n');
fprintf('  Pulse width: ~%.0f ms\n', mean(tone_end - tone_start + 1) / fs * 1000);
fprintf('  Inter-pulse interval: ~%.0f ms\n', ...
    mean(tone_start(2:4) - tone_end(1:3)) / fs * 1000);
fprintf('Figures saved to: %s\n', output_dir);

%% Step 8: Window function comparison (demonstration)
figure('Name', 'Window Function Comparison', 'Position', [100 1500 1200 500]);

% Take a sample tone for comparison
sample_tone = sig(tone_start(1):tone_end(1));

% Rectangular window
win_rect = rectwin(length(sample_tone));
S_rect = fft(sample_tone .* win_rect, N_fft);
S_rect_mag = abs(S_rect(1:N_fft/2+1));

% Hamming window
win_hamm = hamming(length(sample_tone));
S_hamm = fft(sample_tone .* win_hamm, N_fft);
S_hamm_mag = abs(S_hamm(1:N_fft/2+1));

% Hann window
win_hann = hann(length(sample_tone));
S_hann = fft(sample_tone .* win_hann, N_fft);
S_hann_mag = abs(S_hann(1:N_fft/2+1));

% Plot comparison
f_plot = (0:N_fft/2)*fs/N_fft;
plot(f_plot, 20*log10(S_rect_mag + eps), 'b', 'LineWidth', 1.5); hold on;
plot(f_plot, 20*log10(S_hamm_mag + eps), 'r', 'LineWidth', 1.5);
plot(f_plot, 20*log10(S_hann_mag + eps), 'g', 'LineWidth', 1.5);
xlim([600 1600]);
title('Window Function Comparison (First Tone)');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
legend('Rectangular', 'Hamming', 'Hann');
grid on;

% Mark DTMF frequencies
for rf = row_freqs
    xline(rf, 'k:', 'Alpha', 0.3);
end
for cf = col_freqs
    xline(cf, 'k:', 'Alpha', 0.3);
end
