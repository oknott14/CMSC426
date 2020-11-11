function ShapeConfidences = initShapeConfidences(LocalWindows, ColorConfidences, WindowWidth, SigmaMin, A, fcutoff, R)
% INITSHAPECONFIDENCES Initialize shape confidences.  ShapeConfidences is a struct you should define yourself.
    
    ShapeConfidences = cell(1,length(LocalWindows))

    for t = 1:length(LocalWindows)
        
        window = LocalWindows(t);
        colorConfidence = ColorConfidences(t);
        
        shapeConfidence = zeros(size(window))
        
        [l,w] = size(window)
        
        for i = 1:l
            for j = 1:w
                
                %d2x = distance to boundary in colorConfidence
                %sigma = SigmaMin
                
                shapeConfidence(i,j) = 1 - exp(-(d2x^2)/sigma^2)
                
            end
        end
        
        ShapeConfidences(t) = shapeConfidence
    end
end
