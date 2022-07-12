function ideal_steering_vector = idealSteeringVector(azim_range, elev_range)
%idealSteeringVector    Generate ideal steering vector based on direction.
%
%   By Renjie Zhao (r2zhao@ucsd.edu)

    azim_num = length(azim_range);
    elev_num = length(elev_range);
    aoa_unit = zeros(3, azim_num, elev_num);
    azimuth_rad = azim_range/180*pi;
    elevation_rad = elev_range/180*pi;

    % Convert the coordinates
    for ii = 1:azim_num
        for jj = 1:elev_num
            aoa_unit(:,ii,jj) = [cos(azimuth_rad(ii))*cos(elevation_rad(jj)); ...
                sin(azimuth_rad(ii))*cos(elevation_rad(jj)); ...
                sin(elevation_rad(jj))];
        end
    end
    
    % Generate the antenna array geometry matrix
    antenna_number = 36;
    antenna_geometry = zeros(3, antenna_number);
    antenna_spacing = 0.58;
    for ii = 1:antenna_number
        y_id = floor((ii-1)/6);
        x_id = mod((ii-1),6);
        antenna_geometry(:,ii) = [x_id; y_id; 0] * antenna_spacing;
    end
    
    % Calculate the steering vector
    ideal_steering_vector = zeros(antenna_number, azim_num, elev_num);
    for ii = 1:azim_num
        for jj = 1:elev_num
            ideal_steering_vector(:,ii,jj) = exp(1j * 2 * pi * aoa_unit(:,ii,jj).' * antenna_geometry)';
        end
    end
    
    % Convert the element mapping from physical to codebook
    beam_map = [11, 17, 12, 18, 16, 4, 10, 5, 22, 30, 23, 24, 29, 34, 35, 28, 8, 14, 7, 13, 15, 3, 9, 2, 25, 21, 20, 19, 26, 33, 32, 27];
    antenna_map = [0, 24, 22, 6, 8, 0, 19, 17, 23, 7, 1, 3, 20, 18, 21, 5, 2, 4, 28, 27, 26, 9, 11, 12, 25, 29, 32, 16, 13, 10, 0, 31, 30, 14, 15, 0];
    ideal_steering_vector = ideal_steering_vector(beam_map,:,:);

    % Remove constant phase delay of the first antenna element.
    for ii = 32:-1:1
        ideal_steering_vector(ii,:,:) = ideal_steering_vector(ii,:,:) .* conj(ideal_steering_vector(1,:,:));
    end
end