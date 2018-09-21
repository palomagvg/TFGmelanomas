clc
clear all;
close all;
warning off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INFORMACIÓN DEL SCRIPT CLASIFICACIÓN GLOBULES Y STREAKS*: 
% Se crea la base de datos propia a partir del archivo ISIC
% Se balancean los bloques
% Se entrena y prueba la red
%
%*Se utilizan etiquetas de globules y streaks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREACIÓN DE LA BASE DE DATOS PROPIA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Se añade json al path
addpath matlab-json-0.3/matlab-json-0.3/

%Número de imágenes que hay en la carpeta
D=dir('ISBI2016_ISIC_Part2_Training_GroundTruth/ISBI2016_ISIC_Part2_Training_GroundTruth');
[nImagenes dum]=size(D);

%Número de folds y generación de n índices aleatorios (aleatorios de 1 a 5) 
%que se asignarán a cada imagen
numFolds=5;
indicesImagenes = indicesCV(numFolds,nImagenes);

%Se crean los directorios y variables relacionadas con los folds
mkdir('./bloques/util/fold1');
mkdir('./bloques/util/fold2');
mkdir('./bloques/util/fold3');
mkdir('./bloques/util/fold4');
mkdir('./bloques/util/fold5');

valorenFold1=0;
valorenFold2=0;
valorenFold3=0;
valorenFold4=0;
valorenFold5=0;

etiquetasfold1=[];
etiquetasfold2=[];
etiquetasfold3=[];
etiquetasfold4=[];
etiquetasfold5=[];


%Para cada imagen: se obtienen los bloques y etiquetas asociadas 
for i=3:nImagenes
   
    %Nombre de la imagen
    nombre=D(i).name;
    %Imagen 
    imagenes=imread(strcat('ISBI2016_ISIC_Part2_Training_Data/ISBI2016_ISIC_Part2_Training_Data/',nombre(1:12),'.jpg'));
    %Mapa de superpixeles 
    aux_sp=imread(strcat('ISBI2016_ISIC_Part2_Training_Data/ISBI2016_ISIC_Part2_Training_Data/',nombre(1:12),'_superpixels.png'));
    superpixeles=uint32(uint32(aux_sp(:,:,1))+bitshift(uint32(aux_sp(:,:,2)),8)+bitshift(uint32(aux_sp(:,:,3)),16));
    %Máscara 
    mascaras=imread(strcat('ISBI2016_ISIC_Part1_Training_GroundTruth/ISBI2016_ISIC_Part1_Training_GroundTruth/',nombre(1:12),'_Segmentation.png'));
    %Etiquetas de los superpíxeles
    etiquetas=json.read(strcat('ISBI2016_ISIC_Part2_Training_GroundTruth/ISBI2016_ISIC_Part2_Training_GroundTruth/',nombre(1:12),'.json'));
    
    %Se construye el borde alrededor del perimetro
    SE= strel('disk', 15);
    mascInt1=imerode(mascaras, SE);
	SE= strel('disk', 13);
	mascInt2=imerode(mascaras, SE);
	borde= mascInt2-mascInt1;
    
    %Se construyen los bloques alrededor del perimetro de la lesión
    punto=0;
    bloques = struct('b', {});
    tamBloque= 64;
    
    %Se crea una carpeta específica para cada imagen donde se guardarán los
    %bloques
    mkdir('./',nombre(1:12));
    
    %Se saca una matriz del tamaño de la imagen con la etiqueta asociada a
    %cada pixel (a partir del superpixel)
    for a=1:(max(max(superpixeles))+1)
        [row,column]= find(superpixeles==(a-1));
        imagenSuperpixel(row,column,1)= etiquetas.streaks(a);
        imagenSuperpixel(row,column,2)= etiquetas.globules(a);
    end
    
    %Se recorre el borde de manera aleatoria con bloques de 64x64 
    for j=(1+tamBloque/2):round((rand+0.1)*10):(size(borde,1)-tamBloque/2)
        for k=(1+tamBloque/2):round(rand*10):(size(borde,2)-tamBloque/2)
            %Se comprueba si se está en el borde
            if(borde(j,k)==255)
                
                %Contador para dar nombre a las imágenes de los bloques en
                %la carpeta
                punto=punto+1;

                %Cada bloque elegido se guarda en una estructura llamada
                %bloques
                bloque(1:64,1:64,:) = imagenes((j-tamBloque/2)+(0:tamBloque-1),(k-tamBloque/2)+(0:tamBloque-1),:);
                bloques(punto).b= bloque;

                %Se guarda también el bloque como png en la carpeta
                imwrite(bloques(punto).b,strcat('./',nombre(1:12),'/',nombre(1:12),'_block',num2str(punto),'.png'),'png');

                %Se sacan las etiquetas de globules y streaks existentes
                %en el bloque
                valores_streaks(1:64,1:64)= imagenSuperpixel((j-tamBloque/2)+(0:tamBloque-1),(k-tamBloque/2)+(0:tamBloque-1),1);
                valores_globules(1:64,1:64)= imagenSuperpixel((j-tamBloque/2)+(0:tamBloque-1),(k-tamBloque/2)+(0:tamBloque-1),2);
                
                %Se guarda la etiqueta definitiva del bloque
                %Se aplica threshold del 50%
                if(sum(sum(valores_streaks==1))>((64^2)*0.5))
                    etiquetaBloque(punto)=1;
                elseif(sum(sum(valores_globules==1))>((64^2)*0.5))
                    etiquetaBloque(punto)=2;    
                else
                    etiquetaBloque(punto)=0;
                end
                
                %Número de fold correspondiente a la imagen actual
                foldnumero= indicesImagenes(i-2);
                
                %Se va contando el número de bloques guardados en dicho
                %fold para darle nombre a la imagen en la carpeta del fold
                switch foldnumero
                    case 1
                        valorenFold1= valorenFold1+1;
                        auxFold= valorenFold1;
                    case 2
                        valorenFold2= valorenFold2+1;
                        auxFold= valorenFold2;
                    case 3
                       valorenFold3= valorenFold3+1;
                       auxFold= valorenFold3;
                    case 4
                       valorenFold4= valorenFold4+1;
                       auxFold= valorenFold4;
                    case 5
                       valorenFold5= valorenFold5+1;
                       auxFold= valorenFold5;
                end
                
                %Se guarda cada bloque en la carpeta del fold
                %correspondiente
                imwrite(bloques(punto).b,strcat('./bloques/util/fold', num2str(foldnumero) ,'/',num2str(auxFold),'.png'));
            
            end
        end
    end
    
    %Si existen bloques creados
    if((length(dir(strcat('./',nombre(1:12))))-2)~=0)
        
        %Se guardan las etiquetas de los bloques de la imagen en un fichero
        %dat en la carpeta de la imagen
        csvwrite(strcat('./',nombre(1:12),'/etiquetas.dat'),etiquetaBloque);
        
        %Se guardan las nuevas etiquetas de los bloques de la imagen en un
        %vector correspondiente a su fold
        switch foldnumero
            case 1
                etiquetasfold1= [etiquetasfold1 etiquetaBloque];
            case 2
                etiquetasfold2= [etiquetasfold2 etiquetaBloque];
            case 3
                etiquetasfold3= [etiquetasfold3 etiquetaBloque];
            case 4
                etiquetasfold4= [etiquetasfold4 etiquetaBloque];
            case 5
                etiquetasfold5= [etiquetasfold5 etiquetaBloque];
        end

        clear etiquetaBloque;
        clear etiquetaBloqueG;
    
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% BALANCEADO DE ETIQUETAS
%%%%%%%%%%%%%%%%%%%%%%%%%%

%Se balancean los bloques en cada fold
nCount=0;
for j=1:numFolds
    
    %Se compara el número de etiquetas de cada clase y se elige el menor
    indicesMelanomaStreak= find((eval(strcat('etiquetasfold',num2str(j))))==1);
    indicesMelanomaGlobule= find((eval(strcat('etiquetasfold',num2str(j))))==2);
    nMin= min(length(indicesMelanomaStreak),length(indicesMelanomaGlobule));
    
    %Se balancean las clases
    if (length(indicesMelanomaStreak)>length(indicesMelanomaGlobule))
       [indicesMelanomaStreak,idx1] = datasample(indicesMelanomaStreak,nMin); 
    else
       [indicesMelanomaGlobule,idx2] = datasample(indicesMelanomaGlobule,nMin);
    end
    melanomaBenigno= find((eval(strcat('etiquetasfold',num2str(j))))==0);
    [indicesMelanomaBenigno,idx] = datasample(melanomaBenigno,nMin);
    
    %Se actualiza el nuevo array de etiquetas del fold
    indicesMelanomas= [indicesMelanomaStreak indicesMelanomaGlobule indicesMelanomaBenigno];
        switch j
            case 1
                etiquetasBalanceadas1= etiquetasfold1(indicesMelanomas);
                clear etiquetasfold1;
                etiquetasfold1=etiquetasBalanceadas1;          
            case 2
                etiquetasBalanceadas2= etiquetasfold2(indicesMelanomas);
                clear etiquetasfold2;
                etiquetasfold2=etiquetasBalanceadas2;
            case 3
                etiquetasBalanceadas3= etiquetasfold3(indicesMelanomas);
                clear etiquetasfold3;
                etiquetasfold3=etiquetasBalanceadas3;
            case 4
                etiquetasBalanceadas4= etiquetasfold4(indicesMelanomas);
                clear etiquetasfold4;
                etiquetasfold4=etiquetasBalanceadas4;
            case 5
                etiquetasBalanceadas5= etiquetasfold5(indicesMelanomas);
                clear etiquetasfold5;
                etiquetasfold5= etiquetasBalanceadas5;
        end

     n= length(indicesMelanomas);
     
     %Se crea el array de imágenes de bloques del fold 
     for k=(1+nCount):(n+nCount)
        arrayimagenes(:,:,:,k)=imread(strcat('./bloques/util/fold',num2str(j),'/',num2str(indicesMelanomas(k-nCount)),'.png'));
     end
     indicesBloquesCV(1,1+nCount:n+nCount)=j;
     nCount= nCount + n;

     clear indicesMelanomas;
     clear indicesMelanomaBenigno;
     clear indicesMelanomaStreak;
     clear indicesMelanomaGlobule;
end

%Se guarda en cada carpeta fold las etiquetas de cada fold
csvwrite(strcat('./bloques/util/fold',num2str(1),'/etiquetas.dat'),etiquetasfold1);
csvwrite(strcat('./bloques/util/fold',num2str(2),'/etiquetas.dat'),etiquetasfold2);
csvwrite(strcat('./bloques/util/fold',num2str(3),'/etiquetas.dat'),etiquetasfold3);
csvwrite(strcat('./bloques/util/fold',num2str(4),'/etiquetas.dat'),etiquetasfold4);
csvwrite(strcat('./bloques/util/fold',num2str(5),'/etiquetas.dat'),etiquetasfold5);

%Array final de etiquetas (con todas las etiquetas de todos los folds)
%ordenado para el entrenamiento y el test
arrayetiquetas= [etiquetasfold1 etiquetasfold2 etiquetasfold3 etiquetasfold4 etiquetasfold5];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ENTRENAMIENTO Y TEST DE LA RED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numClasses= 3; %streaks, globules, otros
completeY =[];
completeScores = [];
completepredictedLabelsTest=[];
infoFolds=0;

%Selección de la red que se desea entrenar
layers = newNetFunction(numClasses);
%layers = leNetFunction(numClasses);
%layers =alexNetFunction(numClasses);


for r=1:numFolds
    
    %Se cogen los bloques del fold actual para validación y el resto para
    %train
    ind_tr = find(indicesBloquesCV~=r);
	ind_val = find(indicesBloquesCV==r);
	trainingImages = arrayimagenes(:,:,:,ind_tr);
	trainingY = arrayetiquetas(:,ind_tr);
	testImages = arrayimagenes(:,:,:,ind_val);
	testY = arrayetiquetas(:,ind_val);

    %Opciones de entrenamiento
    miniBatchSize = 16;
    learningRate= 0.001;
  
    options= trainingOptions('sgdm', 'InitialLearnRate', learningRate, ...
        'Plots', 'training-progress');

    %%%%%Entrenamiento
    [netTransfer,trainInfo] = trainNetwork(trainingImages,categorical(trainingY'),layers,options);

    %%%%%Test
    %Clasificación
    [predictedLabelsTest, scores] = classify(netTransfer,testImages);
    %Media de acierto del fold
    accuracy(1,r)= sum(predictedLabelsTest == categorical(testY'))/numel(testY');
    
    %Se concatenan para todos los folds las etiquetas, las etiquetas
    %predichas, y la probabilidad de las etiquetas
    completeY= cat(1,completeY,testY');
    completepredictedLabelsTest = cat(1,completepredictedLabelsTest,predictedLabelsTest);
    completeScores = cat(1,completeScores,scores);
    
end

%media y varianza del acierto en los distintos folds
meanAccuracy= mean(accuracy);
desvAccuracy= std(accuracy);

