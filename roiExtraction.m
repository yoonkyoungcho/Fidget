function calibrationim = roiExtraction (inputImage, templateimage)
% code for extract roi by image correlation matching
% please download corrMatching function from following link:
% https://www.mathworks.com/matlabcentral/fileexchange/28590-template-matching-using-correlation-coefficients

templateimage = imrotate(templateimage,180);
templateimage_gpu = gpuArray(templateimage);
load('color_markers_scan.mat');

rim = inputImage;

rim = imrotate(rim,180);
rim_gpu = gpuArray(rim);
%     tic
[corrScore, boundingBox] = corrMatching(rim_gpu,templateimage_gpu);
recrim = insertObjectAnnotation(rim, 'rectangle',...
    boundingBox,[1:size(boundingBox,1)],...
    'FontSize',72,'color','g','LineWidth', 5);
figure(101); imshow(recrim);
%     tightfig;
set(gcf,'position',[2561         -55         900        1483]);
figure(11); set(gcf,'position',[9           9        1202        1347]);
subplot(2,2,[1 3]);
imshow(recrim);

for jdx = 1:size(boundingBox,1)
    figure(11);
    %%
    subplot(2,2,2);
    pim = imcrop(rim, boundingBox(jdx,:));
    imshow(pim); hold on;
    title(jdx);
    [centers,radii] = imfindcircles(pim(:,:,3),[100 150]/2,'ObjectPolarity','dark', ...
        'Sensitivity',0.95)
    h = viscircles(centers,radii,'color','g');
    hold on;
    plot(centers(1),centers(2),'g+');

    % create circle
    imageSizeX = size(pim,2);
    imageSizeY = size(pim,1);
    [columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
    % Next create the circle in the image.
    centerX = centers(2);
    centerY = centers(1);
    radius = radii-10;
    circlePixels = (rowsInImage - centerY).^2 ...
        + (columnsInImage - centerX).^2 <= radius.^2;

    % circle image
    cim = double(pim).*repmat(circlePixels,[1 1 3]);
    cimInv = double(pim).*repmat(1-circlePixels,[1 1 3]);

    meanrgbvals = zeros([1 3]);
    for cidx = 1:3
        ccim = cim(:,:,cidx);
        ccim = ccim(:);
        ccim(ccim == 0) = [];
        meanrgbvals(cidx) = mean(ccim);
    end

    cimlab = rgb2lab(uint8(cim));
    ciminvlab = rgb2lab(uint8(cimInv));
    meanlabvals = zeros([1 3]);
    meanlabvalsInv = zeros([1 3]);
    for cidx = 1:3
        ccim = cimlab(:,:,cidx);
        ccim = ccim(:);
        ccim(ccim == 0) = [];
        meanlabvals(cidx) = mean(ccim);


        ccim = ciminvlab(:,:,cidx);
        ccim = ccim(:);
        ccim(ccim == 0) = [];
        meanlabvalsInv(cidx) = mean(ccim);
    end

    xlabel(['rgb = ',num2str(meanrgbvals),'\newlinelab = ',num2str(meanlabvals)]);

    nColors =2;
    color_labels = 0:nColors-1;
    a = double(cimlab(:,:,2));
    b = double(cimlab(:,:,3));
    labdistance = zeros([size(a), nColors]);
    for count = 1:nColors
      labdistance(:,:,count) = ( (a - color_markers(count,1)).^2 + ...
                          (b - color_markers(count,2)).^2 ).^0.5;
    end

    measureim = labdistance(:,:,2).*circlePixels;
    subplot(2,2,4);
    imagesc(measureim); daspect([ 1 1 1]);
    measureim(measureim ==0) = NaN;
    colormeasures = nanmean(measureim(:));
    xlabel(['Color measurement = ',num2str(colormeasures)]);

%     %% create data
%     samplename = inputdlg('Sample Name: e.g. s8057-1-left-1');
%     figure(11);
%     sampledata = measureim;
%     measureimwonan = measureim; measureimwonan(isnan(measureimwonan)) = [];
%     samplestat = [mean(measureimwonan) median(measureimwonan), mode(measureimwonan)];
%     originalpic = pim;
% 
%     sampleStruct.samplename = samplename;
%     sampleStruct.sampledata = sampledata;
%     sampleStruct.samplestat = samplestat;
%     sampleStruct.originalpic = originalpic;
%     sampleStruct.circlepic = uint8(cim);
%     sampleStruct.imageorigin = baseDirInfo(wishList(idx)).name;
% 
%     %% save data
%     save(fullfile(saveDir,[samplename{1},'.mat']),'sampleStruct');
    calibrationim = export_fig('-png');
    imwrite(calibrationim,fullfile(saveDir,[samplename{1},'.png'])...
        ,'png','compression','none');

end
   