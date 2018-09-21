function [layers] = newNet(numClasses)

    %Definición de capas para configuración de la nueva red
    
    layers=[
    imageInputLayer([64 64 3])
    convolution2dLayer(5,16,'Stride',1,'Padding',1)
    maxPooling2dLayer(2,'Stride',2, 'Padding',0)
    convolution2dLayer(5,32,'Stride',1,'Padding',1)
    maxPooling2dLayer(2,'Stride',2, 'Padding',0)
    convolution2dLayer(5,64,'Stride',1,'Padding',1)
    maxPooling2dLayer(2,'Stride',2, 'Padding',0)
    convolution2dLayer(5,128,'Stride',1,'Padding',1)
    fullyConnectedLayer(50)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
    ];

end

