%% Fase 6: Modelo de detección automática. Procesado de datos

close all; clear all;
T0=load('T_sinincorrect.mat');T=T0.T;
[N, P]=size(T);variables=T.Properties.VariableNames;
%% Exploratory data analysis and Preprocessing
% Missingness map

close all;
imagesc(ismissing(T));
xticks(1:P);xticklabels(variables);
title('Missingness map');xlabel('Variable');ylabel('Data sample');set(gca,"XGrid","off","YGrid","on");

for i=4:P
    column=T{:, i};
    Missing=sum(isnan(column));
    if Missing~=0
        X=[variables{1,i},' tiene valores que faltan'];
        disp(X)
    end
end
%%
MissingVal=find(isnan(T.Correlacion_glcm_blue));MissingVal=sort(MissingVal,'descend')
for i=1:4
    NumMiss=MissingVal(i,1);
    T(NumMiss,:)=[];
end
[N, P]=size(T);
variables=T.Properties.VariableNames;
%%
for i=4:P
    column=T{:, i};
    Missing=sum(isnan(column));
    if Missing~=0
        X=[variables{1,i},' tiene valores q faltan'];
        disp(X)
    end
end
%% 
% Ya no hay valor alguno que falte
% Correlation matrix

columns=variables(4:end);Tcorr=T(:,columns);%quitar name, quality y glaucoma para correlacion
Tcorr=table2array(Tcorr);
R=corrcoef(Tcorr);
% Distribución imagenes

close all;
Tcategorical=categorical(T.glaucoma,[0,1],{'Sano','Glaucoma'});
histogram(categorical(Tcategorical))
%% 
% Al haber bastantes mas casos sanos que de glaucoma, para entrenar el modleo 
% de machine leraning se requiere que los datos esten estratificados
%% Machine Learning

%Separacion de datos estratificada para entrenar el modelo, asi se mantiene una balanza de clases

TStratified=T;
NGlaucoma=sum(T.glaucoma==1);NSano=sum(T.glaucoma==0);
Diferencia=NSano-NGlaucoma
FindSano=find(T.glaucoma==0);FindSano=sort(FindSano,'descend');

for i=1:Diferencia
    j=FindSano(i);
    TStratified(j,:)=[];
end
NGlaucoma=sum(TStratified.glaucoma==1)
NSano=sum(TStratified.glaucoma==0)
%%
%por medio de Classification Learner se ha desarrollado el modelo de
%clasificacion
load('BinaryGLMLogisticRegressionModel.mat');