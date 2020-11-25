function ColorModels = initializeColorModels(IMG, Mask, MaskOutline, LocalWindows, BoundaryWidth, WindowWidth)
% INITIALIZAECOLORMODELS Initialize color models.  ColorModels is a struct you should define yourself.
%
% Must define a field ColorModels.Confidences: a cell array of the color confidence map for each local window.
len = length(LocalWindows);
confidence = cell(1,len);
model = cell(1,len);
mask = cell(1,len);
perim = cell(1,len);
dist = cell(1,len);

for t = 1:length(LocalWindows)

    % Isolate current window, mask, and outline
    %-----------------------------------------%
    wXY = LocalWindows(t,:);
    wX = wXY(2);
    wY = wXY(1);
    rad = WindowWidth/2;
    startX = wX - rad;
    endX = wX + rad - 1;
    startY = wY - rad;
    endY = wY + rad - 1;
    window = IMG(startX:endX,startY:endY,:);
    windowMask = Mask(startX:endX,startY:endY,:);
    windowOutline = MaskOutline(startX:endX,startY:endY,:);
    D = bwdist(windowOutline);
    
    %save values to ColorModels
    perim{t} = windowOutline;
    dist{t} = D;
    mask{t} = windowMask;
    
    % Seperate foreground and background colors
    %----------------------------------------%
    %isolate foreground
    [yf,xf] = find(windowMask);
    [yb,xb] = find(~windowMask);
    %need to find orthogonal vectors from the perimiter to the points in
    %the mask, eliminating points with a dist less than Boundary Width
    
    %Get foreground and background RGB colors
    rf = zeros(size(xf));
    gf = zeros(size(xf));
    bf = zeros(size(xf));
    
    rb = zeros(size(xb));
    gb = zeros(size(xb));
    bb = zeros(size(xb));
    
    for i = 1:length(xf)
        rf(i) = window(yf(i),xf(i),1);
        gf(i) = window(yf(i),xf(i),2);
        bf(i) = window(yf(i),xf(i),3);
    end
    
    for i = 1:length(xb)
       rb(i) = window(yb(i),xb(i),1);
       gb(i) = window(yb(i),xb(i),2);
       bb(i) = window(yb(i),xb(i),3);
    end
    
    %Nx3 RGB values seperated by column
    fgX = [rf,gf,bf];
    bgX = [rb,gb,bb];
    
    %3 component distributions in 3 dimensions
    fgDist = fitgmdist(fgX,3,'RegularizationValue',0.1);
    bgDist = fitgmdist(bgX,3,'RegularizationValue',0.1);
    
    %Distribution PDFs among the segmented
    r = reshape(window(:,:,1), [WindowWidth^2 1]);
    g = reshape(window(:,:,2), [WindowWidth^2 1]);
    b = reshape(window(:,:,3), [WindowWidth^2 1]);
    pdfX = [r,g,b];
    
    fgPDF = pdf(fgDist,pdfX);
    bgPDF = pdf(bgDist,pdfX);
    
    fgModel = reshape(fgPDF, [WindowWidth WindowWidth]);
    bgModel = reshape(bgPDF, [WindowWidth WindowWidth]);
    
    localModel = fgModel ./ (fgModel + bgModel);
    
    model{t} = localModel;
    
    %%Find Color Model Confidences.
    Lt = windowMask;
    pc = localModel;
    wc = D;
    
    numerator = sum(sum(abs(Lt-pc) .* wc));
    denominator = sum(wc, 'all');
    
    confidence{t} = 1 - (numerator/denominator);
end

ColorModels = struct('Confidences', {confidence}, 'Model', {model}, 'Mask', {mask},...
    'Perim', {perim}, 'PerimDistance', {dist});

end

