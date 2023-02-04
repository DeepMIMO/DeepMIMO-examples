%% Generate dataset
addpath(genpath('DeepMIMO-5GNR'))
%
% Load the provided dataset parameters
%
dataset_params = read_params('Example_1_params.m');

%
% Generate the dataset with the loaded parameters
%
[DeepMIMO_dataset, dataset_params] = DeepMIMO_generator(dataset_params);

%% Variable inspection
%
% Select a user and basestation pair
%
% *Note: These variables will be used later to select a single user.*
%
bs = 1; ue = 1; 

% Let's check the size of the dataset
size_of_channel = size(DeepMIMO_dataset{bs}.user{ue}.channel)

% Path parameters
DeepMIMO_dataset{bs}.user{ue}.path_params

% Check velocity and travel direction of the UE
velocity = DeepMIMO_dataset{bs}.user{ue}.path_params.velocity;
travel_dir_sph = DeepMIMO_dataset{bs}.user{ue}.path_params.travel_dir;
[tr_x, tr_y, tr_z] = sph2cart(deg2rad(travel_dir_sph(1)), deg2rad(90-travel_dir_sph(2)), velocity);
travel_dir = [tr_x, tr_y, tr_z];


%% Plot an example channel
%
% An example channel magnitude response is plotted for OFDM symbols through time.
%
channel = DeepMIMO_dataset{bs}.user{ue}.channel;

channel_plot = abs(squeeze(channel(:, 1, 1, :)));
subcarriers = 1:dataset_params.OFDM_sampling_factor:dataset_params.OFDM_limit;
OFDM_symbols = 1:1:(14*dataset_params.CDL_5G.num_slots);

figure;

subplot(2 ,1, 1);
surf(OFDM_symbols, subcarriers, channel_plot');
shading('flat');
xlabel('OFDM Symbols');
ylabel('Subcarriers');
zlabel('|H|');
title('Channel Magnitude Response');
view(-75, 35)


subplot(2,1,2);
imagesc(OFDM_symbols, subcarriers, channel_plot');
set(gca,'YDir','normal') % Invert Y axis (subcarriers)
shading('flat');
xlabel('OFDM Symbols');
ylabel('Subcarriers');
zlabel('|H|');
title('Channel Magnitude Response');
view(0, 90)

%% Plot the position and velocity of a user
%
% Plot the basestation position, user position and velocity of a single user.
%
bs_loc = DeepMIMO_dataset{bs}.loc;

ue_loc = DeepMIMO_dataset{bs}.user{ue}.loc;
travel_vector = travel_dir / 3.6; % m/s
figure;
scatter3(bs_loc(1), bs_loc(2), bs_loc(3), 'bo');
hold on
scatter3(ue_loc(1), ue_loc(2), ue_loc(3), 'rx');
quiver3(ue_loc(1), ue_loc(2), ue_loc(3), travel_vector(1), travel_vector(2), travel_vector(3), 1, 'k')
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');

%% Path loss of the users
%
% We combine the positions of the users along with the combined path-loss
% variables to plot it with the basestation location.
%
bs_loc = DeepMIMO_dataset{bs}.loc;
num_ue = 362;

ue_locs = zeros(num_ue, 3);
ue_pl = zeros(num_ue, 1);
for ue = 1:362
    ue_locs(ue, :) = DeepMIMO_dataset{bs}.user{ue}.loc;
    ue_pl(ue) = DeepMIMO_dataset{bs}.user{ue}.pathloss;
end

figure;
scatter3(ue_locs(:, 1), ue_locs(:, 2), ue_locs(:, 3), [], ue_pl);
hold on
scatter3(bs_loc(1), bs_loc(2), bs_loc(3), 'bo');
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
title('Path Loss (dB)')
colorbar()

%%  Reconstruct the CDL channel object
%
% Can be used with the MATLAB CDL channel visualization tools to check
% the transmit and receive antennas (shape and orientation), along with the channel paths.
%
ue = 1;
channel_path_parameters = DeepMIMO_dataset{bs}.user{ue}.path_params;
txSize = dataset_params.CDL_5G.bsAntenna{bs};
txOrientation = dataset_params.CDL_5G.bsOrientation{bs}; % BS Orientation from dataset params
txPolarization = dataset_params.CDL_5G.bsPolarization+1; % BS Polarization for BS-UE channel
rxSize = dataset_params.CDL_5G.ueAntSize;
rxOrientation = channel_path_parameters.rxArrayOrientation; % UE Orientation from path params
rxPolarization = dataset_params.CDL_5G.uePolarization+1; % UE Polarization for BS-UE channel

CDL_channel = construct_DeepMIMO_CDL_channel(txSize, txOrientation, txPolarization, rxSize, rxOrientation, rxPolarization, dataset_params, channel_path_parameters);

% Visualize the RX and TX antennas with MATLAB 5G Toolbox functions:
CDL_channel.displayChannel('LinkEnd','Tx');
CDL_channel.displayChannel('LinkEnd','Rx');
