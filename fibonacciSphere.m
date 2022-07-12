function [azimuth, elevation] = fibonacciSphere(samples)
%fibonacciSphere    Generate even distributed samples on a sphere
%
%   By Renjie Zhao (r2zhao@ucsd.edu)

    offset = 2/samples/4;
    increment = pi * (3 - sqrt(5));
    
    x = zeros(1,samples);
    y = zeros(1,samples);
    z = zeros(1,samples);
    for i = 0:samples - 1
        z(i+1) = -(((i * offset) - 1) + (offset / 2));
        r = sqrt(1 - z(i+1).^2);

        phi = mod((i + 1), samples) * increment;

        x(i+1) = cos(phi) * r;
        y(i+1) = sin(phi) * r;
    end
    [azimuth,elevation,~] = cart2sph(x,y,z);
    azimuth = rad2deg(azimuth);
    elevation = rad2deg(elevation);
end