%% This will analyse both images from matlab processed and fpga processed
close all; clear all;
%% Open matlab image after downsampling
try 
    matlabImage = rgb2gray(imread('image.jpg'));
catch
    matlabImage = rgb2gray(imread('image.png'));
end
[h,w] = size(matlabImage);
matlabImage = im2double(matlabImage);
%% Gaussian Filter
GF = zeros(h,w);
for i = 2:h-1
    for j = 2:w-1 % {[1,2,1],[2,4,2],[1,2,1]}/16 Gaussian Kernal
        sum = 0;
        sum = sum + matlabImage(i-1,j-1) + matlabImage(i-1,j)*2;
        sum = sum + matlabImage(i-1,j+1) + matlabImage(i,j-1)*2;
        sum = sum + matlabImage(i,j)*4 + matlabImage(i,j+1)*2;
        sum = sum + matlabImage(i+1,j-1) + matlabImage(i+1,j)*2;
        sum = sum + matlabImage(i+1,j+1);
        GF(i,j) = sum/16;
    end
end
%% Downsample image with Matlab
DownsampledImageMatlab = zeros(128,128);
for m = 1:2:255
    for n = 1:2:255
        DownsampledImageMatlab((m+1)/2,(n+1)/2) = (GF(m,n) + GF(m,n+1) + GF(m+1,n) + GF(m+1,n+1)) / 4;
    end
end
modifiedImage = mat2gray(DownsampledImageMatlab(2:127, 2:127));
figure;
imshow(modifiedImage);

%% Creates output image from the hex file generated by FPGA
%% Open the hex file
hexFile = fopen('Image.hex', 'r');
%% Read the hex file to an image and close it
img = fscanf(hexFile, '%x', [1 inf]);
fclose(hexFile); 
%% Reshape the image to a 256 x 256 image and display
outImg = reshape(img,[256 256]);
outImg = imrotate(outImg, 90);
% figure, imshow(outImg,[]);
%% Extract the final output and save it
finalRender = mat2gray(outImg(130:255, 1:126));
imwrite(finalRender, 'finalImage.jpg');
figure, imshow(finalRender,[]);
%% Convert images to original map
ImagefromFPGA = (finalRender * 255);
ImageFromMatlab = (modifiedImage * 255);
%% %%%%%%%%%%%%%%%%%%%%% ANALYSE %%%%%%%%%%%%%%%%%%%% %%
Difference = cumsum(uint64(abs(ImagefromFPGA - ImageFromMatlab).^2));
MeanSquareError = 0;
for ii = 1:1:126
    MeanSquareError = MeanSquareError + Difference(126,ii);
end
MeanSquareError = MeanSquareError / numel(finalRender);
%% Display Result
fprintf('\n\n\t\t\tMean Square Error is %0.2f\n\n\n', MeanSquareError);