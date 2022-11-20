function outputImage = FrostFilter(inputImage,mask)
if nargin == 1
    mask = getnhood(strel('square',5));
elseif nargin == 2
    if ~islogical(mask)
        error('Mask of neighborhood specified must be a logical valued matrix');
    end
else
    error('Unsupported calling of fcnFirstOrderStatisticsFilter');
end
imageType = class(inputImage);
windowSize = size(mask);
inputImage = padarray(inputImage,[floor(windowSize(1)/2) floor(windowSize(2)/2)],'symmetric','both');
inputImage = double(inputImage);
[nRows,nCols] = size(inputImage);
outputImage = double(inputImage);
[xIndGrid yIndGrid] = meshgrid(-floor(windowSize(1)/2):floor(windowSize(1)/2),-floor(windowSize(2)/2):floor(windowSize(2)/2));
expWeight = exp(-(xIndGrid.^2 + yIndGrid.^2).^0.5);
for i=ceil(windowSize(1)/2):nRows-floor(windowSize(1)/2)
    for j=ceil(windowSize(2)/2):nCols-floor(windowSize(2)/2)
        localNeighborhood = inputImage(i-floor(windowSize(1)/2):i+floor(windowSize(1)/2),j-floor(windowSize(2)/2):j+floor(windowSize(2)/2));
        localNeighborhood = localNeighborhood(mask);
        localMean = mean(localNeighborhood(:));
        localVar = var(localNeighborhood(:));
        alpha = sqrt(localVar)/localMean;
        localWeight = alpha*(expWeight.^alpha);
        localWeightLin = localWeight(mask);
        localWeightLin = localWeightLin/sum(localWeightLin(:));
        outputImage(i,j) = sum(localWeightLin.*localNeighborhood);
    end
end
outputImage = outputImage(ceil(windowSize(1)/2):nRows-floor(windowSize(1)/2),ceil(windowSize(2)/2):nCols-floor(windowSize(2)/2));
outputImage = cast(outputImage,imageType);