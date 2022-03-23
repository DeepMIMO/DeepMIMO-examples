%% Generate a time-domain dataset
addpath('DeepMIMO_functions')

dataset_params = read_params('DeepMIMOv2_example_3_DT_params.m');
[DeepMIMO_dataset, dataset_params] = DeepMIMO_generator(dataset_params);

%% Generate pulses shifted to path ToAs
%
% Select a transmit basestation and a receive user pair.
% Determine time values for the channel to be sampled.
% Generate sinc pulses at path ToA values.
% Plot the result.
%

ue_idx = 1; % First UE
bs_idx = 1; % First BS

path_ToA = DeepMIMO_dataset{bs_idx}.user{ue_idx}.path_params.ToA; % Time of Arrival

BW = dataset_params.bandwidth*1e9;
upsampling_factor = 100;
sampling_duration = (BW*upsampling_factor); % Sampling rate 1/(BW*upsampling_factor)
total_duration = max(path_ToA)*1.5; % A total duration including all paths
t = 0:(1/sampling_duration):total_duration; % the ADC time samples

path_pulses = pulse_sinc((t-path_ToA')*BW); % Generate sinc centered at ToA values - sampled at time samples

figure; 
plot(t, path_pulses)
xlabel('Time (s)')
ylabel('Amplitude')
title('Pulses Shifted to the ToAs')
grid on;

%% Calculate and visualize power delay profile
%
% Multiply time samples of each shifted pulse with the corresponding array response function
% of the path.
%

TD_channel = DeepMIMO_dataset{bs_idx}.user{ue_idx}.channel; % num_RX x num_TX x num_paths
path_pulses = reshape(path_pulses, 1, 1, size(path_pulses, 1), size(path_pulses, 2)); % Make the pulses 1 x 1 x num_paths x time_samples

time_response = squeeze(sum(TD_channel .* path_pulses , 3)); % Elementwise multiplication of the TD channel with pulses result in num_RX x num_TX x num_paths x time_samples 
% Sum over paths to obtain time samples. The resulting matrix size is num_RX x num_TX x time_samples (corresponding to variable t)

figure; 
channel_power = abs(squeeze(time_response(1, 1, :))).^2; % Channel power response from the first BS antenna to the first UE antenna
plot(t, channel_power) 
xlabel('Time (s)')
ylabel('Power')
title('Power Delay Profile')
grid on;