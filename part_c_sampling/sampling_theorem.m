% Part C: Sampling Theorem Investigation
% Study the effects of sampling and reconstruction using Shannon formula

clear; clc; close all;

%% Create output directory for figures
output_dir = '../output_figures';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% (a) Generate 8-cycle sine wave with 512 samples
t = [0:511] * 2*pi/512;  % Time axis, 8 periods over 512 samples
x_sin = cos(t * 8);       % 8 cycles of sine wave

figure('Name', 'Original 8-cycle Sine Wave');
plot(t, x_sin, 'b', 'LineWidth', 1.5);
title('Original Signal: 8-cycle Sine Wave');
xlabel('Time (radians)'); ylabel('Amplitude');
grid on;

%% (b) & (c) Sampling experiments with different rates
% For 8 cycles in 512 samples: samples per cycle = 512/8 = 64
% Nyquist rate: 2 samples per cycle -> T_nyquist = 32 (every 32nd sample)

T_nyquist = 32;  % 2 samples per cycle

fprintf('========================================\n');
fprintf('Sampling Experiments - Sine Wave\n');
fprintf('========================================\n');
fprintf('  Samples per cycle: 64\n');
fprintf('  Nyquist interval T = %d (2 samples/cycle)\n\n', T_nyquist);

% Create comparison figure for sine wave sampling
figure('Name', 'Sine Wave: Sampling Rate Comparison', 'Position', [50 50 1400 900]);

% Above Nyquist rate: T = 16 (4 samples/cycle)
subplot(3, 1, 1);
y16 = shannon_subplot(x_sin, t, 16);
title('Above Nyquist Rate: T=16 (4 samples/cycle) - Perfect Reconstruction');

% At Nyquist rate: T = 32 (2 samples/cycle)
subplot(3, 1, 2);
y32 = shannon_subplot(x_sin, t, 32);
title('At Nyquist Rate: T=32 (2 samples/cycle) - Theoretical Limit');

% Below Nyquist rate: T = 48 (1.33 samples/cycle) - ALIASING!
subplot(3, 1, 3);
y48 = shannon_subplot(x_sin, t, 48);
title('Below Nyquist Rate: T=48 (1.33 samples/cycle) - ALIASING!');

%% (d) Square wave sampling
% Generate 4-period square wave (MUST be even length for recon.m)
r = [ones(1,64) zeros(1,64)];  % One period (128 samples)
x_square = [r r r r];          % 4 periods = 512 samples

fprintf('========================================\n');
fprintf('Square Wave Sampling\n');
fprintf('========================================\n');
fprintf('  Samples per period: 128\n');
fprintf('  Fundamental frequency: 4 cycles in 512 samples\n');
fprintf('  Note: Square wave has infinite harmonics!\n\n');

figure('Name', 'Original 4-period Square Wave');
plot(t, x_square, 'b', 'LineWidth', 1.5);
title('Original Signal: 4-period Square Wave');
xlabel('Time (radians)'); ylabel('Amplitude');
grid on; ylim([-0.2 1.2]);

% Square wave sampling comparison
figure('Name', 'Square Wave: Sampling Rate Comparison', 'Position', [50 50 1400 900]);

subplot(3, 1, 1);
y_sq16 = shannon_subplot(x_square, t, 32);
title('Square Wave: T=32 (4 samples per period at fundamental)');

subplot(3, 1, 2);
y_sq32 = shannon_subplot(x_square, t, 64);
title('Square Wave: T=64 (2 samples per period at fundamental)');

subplot(3, 1, 3);
y_sq48 = shannon_subplot(x_square, t, 96);
title('Square Wave: T=96 (1.333 samples per period) - Severe Aliasing!');

%% (e) Blood velocity data sampling
% Load blood velocity data from bv.M file in current directory

% Read and parse the bv.M file
fid = fopen('bv.M', 'r');
if fid == -1
    error('Cannot open bv.M file. Please ensure bv.M is in the current directory.');
end

% Read all lines
file_content = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = file_content{1};

% Extract numeric values from lines (skip first line 'tx = [')
x = [];
for i = 2:length(lines)
    line = strtrim(lines{i});
    % Remove trailing '];' if present
    line = strrep(line, '];', '');
    line = strrep(line, 'x = tx.', '');
    line = strrep(line, '''', '');
    line = strrep(line, 'clear tx;', '');
    if ~isempty(line)
        val = str2double(line);
        if ~isnan(val)
            x = [x; val];
        end
    end
end

% Ensure even length for recon function
if mod(length(x), 2) ~= 0
    x = x(1:end-1);  % Remove last element if odd length
end

fprintf('========================================\n');
fprintf('Blood Velocity Data Sampling\n');
fprintf('========================================\n');
fprintf('  Data length: %d samples\n', length(x));

figure('Name', 'Original Blood Velocity Signal');
plot(x, 'b', 'LineWidth', 1.5);
title('Original Blood Velocity Signal');
xlabel('Sample Index'); ylabel('Velocity');
grid on;

% Test different sampling intervals
t_bv = [0:length(x)-1];

figure('Name', 'Blood Velocity: Sampling Comparison', 'Position', [50 50 1400 900]);

subplot(3, 1, 1);
y_bv4 = shannon_subplot(x, t_bv, 4);
title('Blood Velocity: T=4');

subplot(3, 1, 2);
y_bv8 = shannon_subplot(x, t_bv, 8);
title('Blood Velocity: T=8');

subplot(3, 1, 3);
y_bv16 = shannon_subplot(x, t_bv, 16);
title('Blood Velocity: T=16');

fprintf('\nPart C: All sampling experiments completed!\n');
fprintf('Figures saved to: %s\n', output_dir);

%% Local function for subplot (avoids figure overwrite issue)
function y = shannon_subplot(x, t, T)
    % Reconstruct signal using shannon formula for subplot display
    N = length(x);
    y = recon_local(x, T);
    
    % Ensure time axis matches
    M = length(t);
    if M < N
        t = linspace(t(1), (N-1)*t(end)/(M-1), N);
    end
    
    % Get sample points
    x_sample = x(1:T:N);
    t_sample = t(1:T:N);
    
    % Plot
    plot(t, x, 'r-', 'LineWidth', 1.5); hold on;
    plot(t, y, 'g-', 'LineWidth', 1.5);
    plot(t_sample, x_sample, 'bo', 'MarkerSize', 6, 'MarkerFaceColor', 'b');
    grid on;
    xlabel('Time');
    ylabel('Amplitude');
    legend('Original', 'Reconstructed', 'Samples', 'Location', 'best');
end

%% recon function (local copy - same as recon.M)
function y = recon_local(x, n)
    % y = recon(x, n)
    % Sample and reconstruct a periodic array
    % Array must have even length and be strictly periodic
    
    dim = length(x);
    if mod(dim, 2) ~= 0
        error('Input array must have even length for recon.m');
    end
    
    x1 = zeros(1, dim);
    k = 1:n:dim;
    x1(k) = x(k);
    x1 = [x1 zeros(1, dim)];
    theta = pi/n;
    y1 = (1:dim-1)*theta;
    y1 = sin(y1)./y1;
    q1 = y1(dim-1:-1:1);
    y1 = [1 y1 0 q1];
    z1 = fft(x1).*fft(y1);
    z = ifft(z1);
    y = real(z(1:dim));
end
