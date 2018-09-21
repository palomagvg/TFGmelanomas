function [indices] = indicesCV(numFolds,n)

%Devuelve los �ndices para una validaci�n cruzada con numFolds
%folds y n muestras de entrenamiento

%Muestras por fold
n_fold = floor(n/numFolds);

%Se crean array con mismo n�mero de valores del 1 al 5
indices = zeros(n,1);
for i=1:(numFolds-1)
    indices((i-1)*n_fold + 1:i*n_fold) = i;
end
indices((numFolds-1)*n_fold + 1:end) = numFolds;

%Se colocan aleatoriamente
perm = randperm(n);
indices = indices(perm);
end