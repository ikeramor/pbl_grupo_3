%% Fase 6: Modelo de detecci�n autom�tica
%% 
% La extracci�n de caracter�sticas es una parte fundamental en la aplicaci�n 
% de cualquier t�cnica de Machine Learning. El objetivo de esta etapa es identificar 
% patrones discriminativos en las im�genes OCT que permitan a los modelos de clasificaci�n 
% aprender qu� valores de dichos patrones se asocian a una clase u otra, es decir, 
% a un paciente sano o a uno enfermo

close all; clear all;
T0=readtable('metadata.csv');
[N, P]=size(T0);

T=T0;
for i=N:-1:1
    if(T.quality(i)~=4)
        T(i,:)=[];
    end
end
[N, P]=size(T);%dimensiones nueva tabla
variables=T.Properties.VariableNames;
%% 
% Ubicaci�n de las imagenes

ImagePath=fullfile('images');
ImageLocation='';
for i=1:N
    str=string(T{i,1});
    ImagePathFinal=fullfile(ImagePath,str);
    ImageLocation=[ImageLocation,ImagePathFinal];
end
ImageLocation=[ImageLocation(2:end)];
% Extracci�n regi�n de interes (ROI)
% El glaucoma impacta la regi�n del nervio �ptico que se sit�a en la secci�n 
% m�s brillante de la imagen. Por lo tanto, todo dato fuera de esta �rea no aporta 
% informaci�n relevante y pueden ser descartado.

for i=1:N
I=imread(ImageLocation(1,i));

%Extracci�n del canal verde, mejor que el rojo
Ired=I(:,:,2);

%Aplicar filtro promedio para lisar la imagen
w=ones(341)/341^2;
Ifilter=imfilter(Ired,w);

%Busqueda de minimos y sus cordenadas
max_intensidad=max(Ifilter(:));
[filas, columnas] = find(Ifilter == max_intensidad);
punto_central = [round(mean(filas)), round(mean(columnas))];

%Coordenadas centro del disco optico (Mediana de todas las coordenadas)
medianafilas=median(filas); medianacolumnas=median(columnas);

%Coordenadas de la esquina superior izquierda del recorte (900X900)
FilaSI = round(medianafilas - 900/2);
ColumnaSI = round(medianacolumnas - 900/2);
% RealizaR el recorte (900X900)
Icropped = imcrop(I, [ColumnaSI FilaSI 900-1 900-1]);

NombArchivo = string(T{i,1}); %nombre de foto dataset original
%NombArchivo = sprintf('imagen_recortada_%d.png', i);%nombre de foto de 1 a N
path = fullfile('CroppedImages', NombArchivo);
imwrite(Icropped, path); %meter las imagenes cropeadas en una carpeta
end
%% 
% Las imagenes recortadas incorrectamente seran eliminadas y no se tendran en 
% cuenta. Estos son 11 de las 149 que se tienen (el 7%).