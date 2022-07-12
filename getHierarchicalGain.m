function gain = getHierarchicalGain()
%getHierarchicalGain    Generate antenna gain with hierarchical gain
%   This function by default only enable two columns to generate wide
%   beams. Replace the gain matrix with a customed one for a customized
%   codebook.
%
%   By Renjie Zhao (r2zhao@ucsd.edu)

    % Generate a gain matrix corresponds to physical antenna elements
    % [0 0 7 7 0 0]
    % |0 0 7 7 0 0|
    % |0 0 7 7 0 0|
    % |0 0 7 7 0 0|
    % |0 0 7 7 0 0|
    % [0 0 7 7 0 0]
    gain = [0 0 7 7 0 0];
    gain = repmat(gain,1,6);
    
    
    % Convert the physical antenna element mapping to codebook 
    beam_map = [11, 17, 12, 18, 16, 4, 10, 5, 22, 30, 23, 24, 29, 34, 35, 28, 8, 14, 7, 13, 15, 3, 9, 2, 25, 21, 20, 19, 26, 33, 32, 27];
    gain = gain(beam_map);
end