clear all;
clc;
close all;

ant_num = 32;
beam_num = 15;
cb_num = 1;
part_num = ant_num / cb_num;
%full_gain = 7 * ones(ant_num,1);
full_gain = get_hierarchical_gain().';
zero_gain = zeros(ant_num,1);
zero_phase = zeros(ant_num,1);
ref_gain = repmat([7;0], ant_num/2, 1);
ref_amp = 6 * ones(ant_num/4, 1);

load('steer_vector_calib.mat');
angl_step = 3;
elev_range = 30:angl_step:90;
azim_range = 0:angl_step:357;
real_steering_vector = exp(1j * steering_phase);
ideal_steering_vector = IdealSteeringVector(azim_range, elev_range);
steering_vector_diff = real_steering_vector .* conj(ideal_steering_vector);
antenna_phase_shifts = exp(1j * angle(sum(sum(steering_vector_diff,3),2)));


azim_range = [zeros(1,8), 180*ones(1,7)];% [zeros(1,64), 180*ones(1,64)];
elev_range = [37.5:7.5:90 82.5:-7.5:37.5];% [27:90, 90:-1:27];
%[azim_range,elev_range] = fibonacci_sphere(beam_num);

target_steering_vector = zeros(32, length(azim_range));
for ii = 1:length(azim_range)
    target_steering_vector(:,ii) = IdealSteeringVector(azim_range(ii), elev_range(ii));
end
target_steering_vector = target_steering_vector .* repmat(antenna_phase_shifts, 1, length(azim_range));
code_phase = mod(floor((angle(target_steering_vector) + pi/4) / (pi/2)), 4);

codebook_name = {'15beam.mat'};
for ii = 1:cb_num
    beam_weight = cell(1, beam_num);
    for jj = 1:beam_num
        beam_weight{jj} = cell(1,3);
    end
    
    for ll = 1:beam_num
        beam_weight{ll}{1} = num2str(full_gain);
        beam_weight{ll}{2} = num2str(code_phase(:,(ii-1)*beam_num+ll));
        beam_weight{ll}{3} = num2str(ref_amp);
    end
    save(codebook_name{ii}, 'beam_weight');
end


% quant_phase = code_phase .* pi/2 - pi/4;
% 
% beam_map = [11, 17, 12, 18, 16, 4, 10, 5, 22, 30, 23, 24, 29, 34, 35, 28, 8, 14, 7, 13, 15, 3, 9, 2, 25, 21, 20, 19, 26, 33, 32, 27];
% antenna_map = [0, 24, 22, 6, 8, 0, 19, 17, 23, 7, 1, 3, 20, 18, 21, 5, 2, 4, 28, 27, 26, 9, 11, 12, 25, 29, 32, 16, 13, 10, 0, 31, 30, 14, 15, 0];
% ideal_steering_vector = ideal_steering_vector(beam_map,:,:);
% for ii = 32:-1:1
%     ideal_steering_vector(ii,:,:) = ideal_steering_vector(ii,:,:) .* conj(ideal_steering_vector(1,:,:));
% end