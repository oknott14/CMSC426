function ColorModels = initializeColorModels(IMG, Mask, MaskOutline, LocalWindows, BoundaryWidth, WindowWidth)
% INITIALIZAECOLORMODELS Initialize color models.  ColorModels is a struct you should define yourself.
%
% Must define a field ColorModels.Confidences: a cell array of the color confidence map for each local window.
colorModelConfidences = cell(1,length(LocalWindows))
pCl = .5;

for t = 1:length(LocalWindows)
    
    %isolate current local window params
    [wX, wY] = LocalWindows(t);
    rad = WindowWidth/2;
    window = IMG(wX-rad:wX+rad,wY-rad:wY+rad,:);
    windowMask = Mask(wX-rad:wX+rad,wY-rad:wY+rad,:);
    windowOutline = MaskOutline(wX-rad:wX+rad,wY-rad:wY+rad,:);
    
    %find color confidences for local windows
    %isolate foreground
    [xf,yf] = find(windowMask)
    [xb,yb] = find(~windowMask)
    %need to find orthogonal vectors from the perimiter to the points in
    %the mask, eliminating points with a dist less than Boundary Width
    
    rfColors = window(xf(:), yf(:), 1);
    gfColors = window(xf(:), yf(:), 2);
    bfColors = window(xf(:), yf(:), 3);
    rgbfColors = [rfColors; gfColors; bfColors];
    
    rbColors = window(xb(:), yb(:), 1);
    gbColors = window(xb(:), yb(:), 2);
    bbColors = window(xb(:), yb(:), 3);
    rgbbColors = [rbColors; gbColors; bbColors];
    
    %find p(X|Cl)
    fmu = mean(rgbfColors)
    fsigma = cov(rgbfColors)
    fX = window(xf(:),yf(:),:)
    fPdf = mvnpdf(fX,fmu,fsigma)
    
    bmu = mean(rgbbColors)
    bsigma = cov(rgbbColors)
    bX = window(xb(:),yb(:),:)
    bpdf = mvnpdf(bX,bmu,bsigma)
    
    gmmDist = fitgmdist([fpdf;bpdf],2)
    
    localConfidence = zeros(size(window))
    
    for i = 1:WindowWidth
        for j = 1:WindowWidth
            
            pxCl = pdf(gmmDist, window(i,j,:)
            localConfidence(i,j) = pxCl * pCl
            
        end
    end
    
    colorModelConfidences{t} = localConfidence;
    
    
end
    
    
    
    
    
    
    
    
    

end

