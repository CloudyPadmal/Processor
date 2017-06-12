%% Creates HEX file and the grayscale version of the color image
clear all;
close all;
%% Open a 24-bit Image and convert to grayscale
principal_image = imread('image.png');
principal_image = rgb2gray(principal_image);
%% Save the grayscale image for comparisons
imwrite(principal_image, 'grayImage.jpg');
%% Calculate dimensions
[height, width, tones] = size(principal_image);
%% Seperation of individual bits
pixel = 1;
for width = 256 : -1 : 1
    for height = 1 : 256
        bits(pixel) = principal_image(width, height);
        pixel = pixel + 1;
    end
end
%% Create a hex file
hex_image = fopen('imageFile.hex', 'wt');
%% Write bits to hex file
fprintf(hex_image, '%x\n', bits);
disp('Conversion complete!');
%% Close image
fclose(hex_image);