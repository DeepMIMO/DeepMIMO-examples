%% Generate Dataset after changing array rotation parameters
addpath('DeepMIMO_functions')
dataset_params = read_params('DeepMIMOv2_example_2_params.m');

% Generate the dataset with the loaded parameters
[DeepMIMO_dataset, dataset_params] = DeepMIMO_generator(dataset_params);


%% Visualization of an antenna array orientation
%
% Select an active basestation to visualize its antenna array orientation
%
BS_id = 1;

Num_ant_BS = dataset_params.num_ant_BS(BS_id,:);
Array_rotation_BS = DeepMIMO_dataset{BS_id}.rotation;
Ant_spacing_BS = dataset_params.ant_spacing_BS(BS_id);
Carrier_freq = dataset_params.carrier_freq;

Visualize_ant_array_orientation(Num_ant_BS,Array_rotation_BS,Ant_spacing_BS,Carrier_freq)
