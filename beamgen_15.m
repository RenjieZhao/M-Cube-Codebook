%beamgen_15     Generate a codebook file with 15 beams
%   Modify the code for a customized codebook
%
%   Check figure 4 of paper 'Adaptive Codebook Optimization for Beam
%   Training on Off-the-Shelf IEEE 802.11ad Devices' for the physical
%   meaning of the codebook.
%
%   The codebook contains three parts:
%   ant_gain:   Gains of the 32 edge amplifiers of the 32 antenna elements. 
%               The chipset supports the value in the range of [0:7], but 
%               the effective value is binary ([0:3] is off, [4:7] is on). 
%               This is not that important if tapering is not needed.
%   ant_phase:  Phase of the 32 phase shifters of the 32 antenna elements. 
%               The chipset supports the value in the range of [0:3].
%               Therefore, the phase shift is limited to 4 different
%               phases which is the main limitation the beamforming.
%               Calibration is needed to remove additional phase shift
%               introduced by hardware. We derive the phase difference
%               between phase in the codebook and measured phase at
%               different directions in the FoV of one antenna array.
%               Theoretically, the phase shift of different antenna arrays
%               might not be the same, but the calibration result of other
%               phased arrays should be good enough in most cases.                
%   group_gain: Amplifier gains of 8 distribution amplifiers. The chipset
%               supports the value in the range of [0:7], but the effective
%               value is also binary ([0:3] is off, [4:7] is on).
%
%   By Renjie Zhao (r2zhao@ucsd.edu)
clear
clc;
close all;

% 32 elements in total, do not change
ant_num = 32;   

% Beam number should be lower than 128. There is only 128 beam register
% groups on the phased array.
beam_num = 15;

% Output codebook file name
codebook_name = '15beam.mat';

% Enable all antenna elements
ant_gain = 7 * ones(ant_num,1); 
% Uncomment and modify the following function for arbitrary codebook.
% The function by default only enable two columns to generate wide beams
% ant_gain = getHierarchicalGain().'; 

% 4 antenna elements corresponds to one group, force all amplifiers on.
group_gain = 6 * ones(ant_num/4, 1);

% Load the measured data to calculate the calibration matrix for steering
% vector, do not modify.
load('steer_vector_calib.mat');
angl_step = 3;
elev_range = 30:angl_step:90;
azim_range = 0:angl_step:357;
real_steering_vector = exp(1j * steering_phase);
ideal_steering_vector = idealSteeringVector(azim_range, elev_range);
steering_vector_diff = real_steering_vector .* conj(ideal_steering_vector);
antenna_phase_shifts = exp(1j * angle(sum(sum(steering_vector_diff,3),2)));

% Generate a group of beams sweeping in the xz plane. Please first
% understand the axis mapping before doing any modification.
azim_range = [zeros(1,8), 180*ones(1,7)];
elev_range = [37.5:7.5:90 82.5:-7.5:37.5];
% Or uncomment the following line for evenly distributed beams.
% [azim_range,elev_range] = fibonacciSphere(beam_num);

% Generate the steering vector based on the beam directions
% Replace this part with customized steering vector, remember to apply the
% antenna element mapping.
target_steering_vector = zeros(32, length(azim_range));
for ii = 1:length(azim_range)
    target_steering_vector(:,ii) = idealSteeringVector(azim_range(ii), elev_range(ii));
end

% Use measure result to calibrate the phase shift introduced by hardware
target_steering_vector = target_steering_vector .* repmat(antenna_phase_shifts, 1, length(azim_range));

% Quantitize the shifting phase
ant_phase = mod(floor((angle(target_steering_vector) + pi/4) / (pi/2)), 4);

% Pack the ant_gain, ant_phase and group_gain to the file
beam_weight = cell(1, beam_num);
for jj = 1:beam_num
    beam_weight{jj} = {num2str(ant_gain),num2str(ant_phase(:,jj)),num2str(group_gain)};
end
save(codebook_name, 'beam_weight');