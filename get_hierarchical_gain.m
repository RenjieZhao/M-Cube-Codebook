function gain = get_hierarchical_gain()
%     antenna_number = 36;
%     gain = zeros(1,antenna_number);
%     for ii = 1:step:antenna_number
%         gain(ii) = 7;
%     end
    
    gain = [0 0 7 7 0 0];
    gain = repmat(gain,1,6);
    
    beam_map = [11, 17, 12, 18, 16, 4, 10, 5, 22, 30, 23, 24, 29, 34, 35, 28, 8, 14, 7, 13, 15, 3, 9, 2, 25, 21, 20, 19, 26, 33, 32, 27];
    gain = gain(beam_map);
end