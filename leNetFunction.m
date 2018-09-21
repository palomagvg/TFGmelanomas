function [layers] = lenetFunction(numClasses)

    %Definición de capas para configuración adaptada de la red LeNet-5

    layers=[
    imageInputLayer([64 64 3])
    convolution2dLayer(5,6,'Stride',1,'Padding',0)
    averagePooling2dLayer(2,'Stride',2)
    convolution2dLayer(5,16,'Stride',1,'Padding',1)
    averagePooling2dLayer(2,'Stride',2)
    convolution2dLayer(5,120,'Stride',1,'Padding',0)
    averagePooling2dLayer(2,'Stride',2)
    convolution2dLayer(5,180,'Stride',1,'Padding',0)
    fullyConnectedLayer(84) 
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
    ];

end

