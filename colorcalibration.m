function [calibrationim, imWB] = colorcalibration(inputImage)
% The code is for color calibration

tim= inputImage;
primages  = imrotate(tim,180,'bilinear');
primages = primages(1:end/1.5,:,:);
I = primages; 

I = rgb2lin(I);
chart = esfrChart(I);

figure(100);
subplot(3,2,[1 2]);
displayChart(chart);
[colorTable,~] = measureColor(chart);

figure(100);
subplot(3,2,3);
displayColorPatch(colorTable)
subplot(3,2,4);
plotChromaticity(colorTable)

illum = measureIlluminant(chart);
imWB_lin = chromadapt(I,illum,'ColorSpace','linear-rgb');
imWB = lin2rgb(imWB_lin);
figure(100);
subplot(3,2,[5 6]);
imshowpair(lin2rgb(I),imWB,'montage')
title('Original (left) and White-Balanced (right) Test Chart Image')
set(gcf,'position',[ 2           2        1216        1354]);
set(gcf,'color','w');
calibrationim = export_fig('-png');
I = rim; 
I = rgb2lin(I);
imWB_lin = chromadapt(I,illum,'ColorSpace','linear-rgb');
imWB = lin2rgb(imWB_lin);

%svname = fullfile(saveDir, [baseDirInfo(idx).name,'_result.tif']);
%imwrite(imWB,svname,'tif','compression','none');
%svname = fullfile(saveDir, [baseDirInfo(idx).name,'_analysis.png']);
%imwrite(calibrationim,svname,'png','compression','none');
