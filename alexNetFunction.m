function [layers] = alexNetFunction(numClasses)

    %Definición de capas para configuración adaptada de la red AlexNet
    
    layers=[
    imageInputLayer([64 64 3])
    convolution2dLayer(10,96,'Stride',1,'Padding',0)
    maxPooling2dLayer(3,'Stride',2)
    convolution2dLayer(5,256,'Stride',1,'Padding',2)
    maxPooling2dLayer(3,'Stride',2)
    convolution2dLayer(3,384,'Stride',1,'Padding',1)
    convolution2dLayer(3,384,'Stride',1,'Padding',1)
    convolution2dLayer(3,256,'Stride',1,'Padding',1)
    fullyConnectedLayer(410)
    fullyConnectedLayer(410)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
    ];

end
