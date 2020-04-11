function outputImage = spotdetection(inputImage)
% This code is an implementation of a spot detection agorithm suggested by 
% Olivo-Marin, J.-C. Extraction of Spots in Biological Images Using Multiscale Products. 
% Pattern Recognit. 35, 1989–1996 (2002).

    % detection parameter
    k = 3;
    background = 0;
    numberOfScales = 1;
    minComponentSize = 1;
    limitToLocalMaxima = 0;
    ld = 1;
    imageSize = size(inputImage);
    connectivityMode = 4;

    % image preprocess
    A = zeros(imageSize(1),imageSize(2),numberOfScales+1);
    A(:,:,1) = inputImage - background;
    kernel = [1/16 4/16 6/16 4/16 1/16];

    for i = 1:numberOfScales
        kernelOut = atrous(kernel, i);
        A(:,:,i+1) = convolution_mirror_mapping(A(:,:,i), kernelOut);
    end
    W = -diff(A,1,3);
    linearWavelets  = reshape(W,prod(imageSize),1,numberOfScales);
    medianValues    = median(linearWavelets);
    medianValues    = reshape(ones(prod(imageSize),1)*medianValues(:)',prod(imageSize),1,numberOfScales);
    sigmaBars       = median(abs(medianValues - linearWavelets));
    sigmas          = sigmaBars / 0.67;
    thresholds      = k * sigmas;

    for i = 1:numberOfScales
        W(:,:,i) = W(:,:,i) .* (W(:,:,i) >= thresholds(i)/2);
    end
    productedImage  = prod(W,3);
    if ~limitToLocalMaxima
        outputImage = uint16(abs(productedImage) >= max(ld,prod(thresholds)));
    else
        [~,maximaImage] = localextrema(abs(productedImage),ones(3));
        thresholdImage = uint16(abs(productedImage) >= max(ld,prod(thresholds)));

        outputImage = maximaImage & thresholdImage;
        if minComponentSize>=1
            binaryImage = logical(imfill(thresholdImage, 'holes'));
            labeledImage = bwlabel(binaryImage, connectivityMode);
            [~,last]=unique(sort(labeledImage(:)));
            nPerComponent = diff(last);
            compIndex = labeledImage(binaryImage);
            valid = nPerComponent(compIndex)>minComponentSize;
            binaryImage(binaryImage) = valid;
            outputImage = maximaImage & binaryImage;
        end
    end
