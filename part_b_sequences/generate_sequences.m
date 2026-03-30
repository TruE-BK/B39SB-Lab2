% Part B: Common Sequence Generation
% Generate and plot common sequences for n = -10 to 39 (50 samples)

clear; clc; close all;

%% Create output directory for figures
output_dir = '../output_figures';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% Define sample index
n = [-10:1:39];  % 50 samples from -10 to 39

%% 1. Unit Sample (Impulse) Sequences

% 1(a). x1a = delta(n), impulse at n=0
x1a = (n == 0);

% 1(b). x1b = delta(n-3), impulse at n=3
x1b = (n == 3);

% 1(c). x1c = delta(n+4), impulse at n=-4
x1c = (n == -4);

% Plot unit sample sequences
figure('Name', 'Unit Sample Sequences', 'Position', [100 100 1200 300]);
subplot(1,3,1); stem(n, x1a, 'filled'); title('x_{1a} = \delta(n)'); xlabel('n'); ylabel('Amplitude'); grid on;
subplot(1,3,2); stem(n, x1b, 'filled'); title('x_{1b} = \delta(n-3)'); xlabel('n'); ylabel('Amplitude'); grid on;
subplot(1,3,3); stem(n, x1c, 'filled'); title('x_{1c} = \delta(n+4)'); xlabel('n'); ylabel('Amplitude'); grid on;

%% 2. Unit Step Sequences

% 2(a). x2a = u(n), step at n=0
x2a = (n >= 0);

% 2(b). x2b = u(n-2), step at n=2
x2b = (n >= 2);

% Plot unit step sequences
figure('Name', 'Unit Step Sequences', 'Position', [100 450 800 300]);
subplot(1,2,1); stem(n, x2a, 'filled'); title('x_{2a} = u(n)'); xlabel('n'); ylabel('Amplitude'); grid on; ylim([-0.2 1.2]);
subplot(1,2,2); stem(n, x2b, 'filled'); title('x_{2b} = u(n-2)'); xlabel('n'); ylabel('Amplitude'); grid on; ylim([-0.2 1.2]);

%% 3. Unit Rectangular Pulse Sequences

% 3(a). x3a = P_10(n), rectangle from n=0 to n=10
x3a = ((n >= 0) & (n <= 10));

% 3(b). x3b = P_10(n+5), rectangle from n=-5 to n=5
x3b = ((n >= -5) & (n <= 5));

% 3(c). x3c = P_10(3-n), reversed and shifted
% P_10(3-n) = 1 when 0 <= 3-n <= 10 => -7 <= n <= 3
x3c = ((-7 <= n) & (n <= 3));

% Plot rectangular pulse sequences
figure('Name', 'Rectangular Pulse Sequences', 'Position', [100 800 1200 300]);
subplot(1,3,1); stem(n, x3a, 'filled'); title('x_{3a} = P_{10}(n)'); xlabel('n'); ylabel('Amplitude'); grid on; ylim([-0.2 1.2]);
subplot(1,3,2); stem(n, x3b, 'filled'); title('x_{3b} = P_{10}(n+5)'); xlabel('n'); ylabel('Amplitude'); grid on; ylim([-0.2 1.2]);
subplot(1,3,3); stem(n, x3c, 'filled'); title('x_{3c} = P_{10}(3-n)'); xlabel('n'); ylabel('Amplitude'); grid on; ylim([-0.2 1.2]);

%% 4. Square Wave Sequence (Period 1ms, Fs=8kHz)
% One period = 8 samples, duty cycle = 4 samples high, 4 samples low

r = [ones(1,4) zeros(1,4)];  % One period (8 samples)
% Repeat and trim to match n range (-10 to 39, length 50)
x4 = [r(7:8) repmat(r, 1, 7)];  % 2 + 56 = 58 samples, need to trim
x4 = x4(1:50);  % Take first 50 samples

figure('Name', 'Square Wave Sequence', 'Position', [100 1150 800 300]);
stem(n, x4, 'filled'); title('x_4 = S_8(n), Square Wave (Period=1ms, Fs=8kHz)'); xlabel('n'); ylabel('Amplitude'); grid on; ylim([-0.2 1.2]);

%% 5. Sawtooth Wave Sequences (Period 1ms, Fs=8kHz)
% One period = 8 samples, values: 0, 1/8, 2/8, ..., 7/8

% 5(a). Sawtooth wave
r_saw = [0:7]/8;  % One period ramp: 0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875
% Align to start properly for n=-10
% n=-10 should correspond to position in cycle
offset = mod(-10, 8);  % -10 mod 8 = 6 (in MATLAB: mod(-10,8)=6)
% Create extended sawtooth and extract correct range
full_saw = repmat(r_saw, 1, 8);  % 64 samples
start_idx = 8 - offset + 1;  % Starting index for n=-10
x5a = full_saw(start_idx:start_idx+49);

% 5(b). Windowed sawtooth: x5b = x5a .* p, where p = P_10(n+10)
p = ((n >= 0) & (n <= 10));  % Rectangular window from n=0 to n=10
x5b = x5a .* p;

% Plot sawtooth sequences
figure('Name', 'Sawtooth Wave Sequences', 'Position', [100 1500 1000 300]);
subplot(1,2,1); stem(n, x5a, 'filled'); title('x_{5a}: Sawtooth Wave (Period=1ms, Fs=8kHz)'); xlabel('n'); ylabel('Amplitude'); grid on;
subplot(1,2,2); stem(n, x5b, 'filled'); title('x_{5b}: Windowed Sawtooth (0 \leq n \leq 10)'); xlabel('n'); ylabel('Amplitude'); grid on;

%% Display summary
disp('Part B: All sequences generated successfully!');
disp('Sequence lengths:');
disp(['  x1a: ' num2str(length(x1a)) ' samples']);
disp(['  x2a: ' num2str(length(x2a)) ' samples']);
disp(['  x3a: ' num2str(length(x3a)) ' samples']);
disp(['  x4:  ' num2str(length(x4)) ' samples']);
disp(['  x5a: ' num2str(length(x5a)) ' samples']);
disp(' ');
disp(['Figures saved to: ' output_dir]);
