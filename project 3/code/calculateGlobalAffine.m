img1 = imread('C:\Users\Will Spencer\Documents\CMSC426\project3\frames\Frames1\1.jpg');
img2 = imread('C:\Users\Will Spencer\Documents\CMSC426\project3\frames\Frames1\2.jpg');

[a, b, c, d] = calculateGlobalAffine_1(img1, img2, mask, LocalWindows);

% CALCULATEGLOBALAFFINE: finds affine transform between two frames, and applies it to frame1, the mask, and local windows.
function [WarpedFrame, WarpedMask, WarpedMaskOutline, WarpedLocalWindows] = calculateGlobalAffine_1(IMG1,IMG2,mask,Windows)
    % convert input images to grayscale so that they can be used in
    % detectHarrisFeatures
    img1 = rgb2gray(IMG1);
    img2 = rgb2gray(IMG2);
    
    % get corner features of the input images
    img1_features = detectHarrisFeatures(img1);
    img2_features = detectHarrisFeatures(img2);
    
    % get feature vectors for each image
    % pts will be used later to get the location of the matched features
    % once matches have been found
    [extract1, pts1] = extractFeatures(img1, img1_features);
    [extract2, pts2] = extractFeatures(img2, img2_features);
    
    % match features from both images using the features extracted from
    % both images 
    pairs = matchFeatures(extract1, extract2);
    
    % get the matched features from both images
    match1 = pts1(pairs(:,1));
    match2 = pts2(pairs(:,2));
    
    % calculate the affine transformation between the 2 frames using the
    % matched points that we found earlier
    trans = estimateGeometricTransform(match1, match2, 'affine');
    
    % warp the image and the mask using the transformation matrix we just
    % calculated. the new warped frame will adjust the object of interest 
    % in IMG1 to be in the new location as it is in IMG2
    WarpedFrame = imwarp(IMG1, trans);
    WarpedMask = imwarp(mask, trans);
    
    figure;
    imshow(WarpedMask)
    
    % apply the affine transformation to the x and y coordinates of our
    % windows. we use transformPointsForward because we need to apply a
    % forward geometric transformation to update the location of the
    % windows in the new frame
    [x, y] = transformPointsForward(trans, Windows(:,1), Windows(:,2));
    WarpedLocalWindows = [x y];
    
    figure;
    imshow(IMG1)
    hold on
    showLocalWindows(WarpedLocalWindows,25,'r.');
    hold off
    
    % bwperim gets the perimeter of objects in a binary image
    WarpedMaskOutline = bwperim(WarpedMask);
    
    figure;
    imshow(WarpedMaskOutline)
end

