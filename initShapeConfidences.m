function ShapeConfidences = initShapeConfidences(LocalWindows, ColorConfidences, WindowWidth, SigmaMin, A, fcutoff, R)
% INITSHAPECONFIDENCES Initialize shape confidences.  ShapeConfidences is a struct you should define yourself.

allFc = ColorConfidences.Confidences;
    
SegmentationMasks = ColorConfidences.Mask;
ShapeConfidence = cell(1,length(LocalWindows));
for t = 1:length(LocalWindows)
  
    %Initialize local shape model
    D = ColorConfidences.PerimDistance{t};
    
    %Calculate shape confidence
    fc = allFc{t};
    if (fcutoff < fc && fc <= 1) 
        sigma = SigmaMin + A(fc - fcutoff)^R;
    else 
        sigma = SigmaMin;
    end
    
    %Save ShapeConfidence model
    ShapeConfidence{t} = 1 - (exp(-(D.^2)./(sigma^2)));
    
    
end

ShapeConfidences = struct('ShapeConfidence', {ShapeConfidence}, 'Mask', {SegmentationMasks});

end
