%% Fase 6: Modelo de detección automática
%% 
% La extracción de características es una parte fundamental en la aplicación 
% de cualquier técnica de Machine Learning. El objetivo de esta etapa es identificar 
% patrones discriminativos en las imágenes OCT que permitan a los modelos de clasificación 
% aprender qué valores de dichos patrones se asocian a una clase u otra, es decir, 
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
% Ubicación de las imagenes

ImagePath=fullfile('images');
ImageLocation='';
for i=1:N
    str=string(T{i,1});
    ImagePathFinal=fullfile(ImagePath,str);
    ImageLocation=[ImageLocation,ImagePathFinal];
end
ImageLocation=[ImageLocation(2:end)];
% Extracción región de interes (ROI)
% El glaucoma impacta la región del nervio óptico que se sitúa en la sección 
% más brillante de la imagen. Por lo tanto, todo dato fuera de esta área no aporta 
% información relevante y pueden ser descartado.

for i=1:N
I=imread(ImageLocation(1,i));

%Extracción del canal verde, mejor que el rojo
Igreen=I(:,:,2);

%Aplicar filtro promedio para lisar la imagen
w=ones(341)/341^2;
Ifilter=imfilter(Igreen,w);

%Busqueda de minimos y sus cordenadas
max_intensidad=max(Ifilter(:));
[filas, columnas] = find(Ifilter == max_intensidad);
punto_central = [round(mean(filas)), round(mean(columnas))];

%Coordenadas centro del disco optico (Mediana de todas las coordenadas)
medianafilas=median(filas); medianacolumnas=median(columnas);

%Coordenadas de la esquina superior izquierda del recorte (900X900)
FilaSI = round(medianafilas - 900/2);
ColumnaSI = round(medianacolumnas - 900/2);


%aumentarel contraste de la imagen
%Icontraste=adapthisteq(Igreen);

% RealizaR el recorte (900X900)
Icropped = imcrop(Igreen, [ColumnaSI FilaSI 900-1 900-1]);


NombArchivo = string(T{i,1}); %nombre de foto dataset original
%NombArchivo = sprintf('imagen_recortada_%d.png', i);%nombre de foto de 1 a N
path = fullfile('CroppedImages', NombArchivo);
imwrite(Icropped, path); %meter las imagenes cropeadas en una carpeta
end
%% 
% Las imagenes recortadas incorrectamente seran eliminadas y no se tendran en 
% cuenta. Estos son 11 de las 149 que se tienen (el 7%).


%% 
% Ubicación de las imagenes cropeadas

CroppedImagePath=fullfile('CroppedImages');
CroppedImageLocation='';
for i=1:N
    str=string(T{i,1});
    CroppedImagePathFinal=fullfile(CroppedImagePath,str);
    CroppedImageLocation=[CroppedImageLocation,CroppedImagePathFinal];
end
CroppedImageLocation=[CroppedImageLocation(2:end)];
% ELIMINACIÓN VASOS SANGUINEOS

for i=1:N
I0=imread(ImageLocation(i));
IR=I0(:,:,1);IG=I0(:,:,2);IB=I0(:,:,3);

ElemEstrukt=strel("disk",15);%bajar 
%1. Dilatacion
IdilateR=imdilate(IR,ElemEstrukt);IdilateG=imdilate(IG,ElemEstrukt);IdilateB=imdilate(IB,ElemEstrukt);
%2. Erosion
IerodeR=imerode(IdilateR,ElemEstrukt);IerodeG=imerode(IdilateG,ElemEstrukt);IerodeB=imerode(IdilateB,ElemEstrukt);
Inew=I0;
Inew(:,:,1)=IerodeR;Inew(:,:,2)=IerodeG;Inew(:,:,3)=IerodeB;
%3. Grayscale
IGray=rgb2gray(Inew);

NombArchivo = string(T{i,1}); %nombre de foto dataset original
path = fullfile('NoVeinsImages', NombArchivo);
imwrite(IGray, path); %meter las imagenes cropeadas en una carpeta
end
%% 
% Ubicación de las imagenes sin vasos

NVImagePath=fullfile('NoVeinsImages');
NVImageLocation='';
for i=1:N
    str=string(T{i,1});
    NVImagePathFinal=fullfile(NVImagePath,str);
    NVImageLocation=[NVImageLocation,NVImagePathFinal];
end
NVImageLocation=[NVImageLocation(2:end)];
% Segmentación
% Filtrado mediano de las imagenes recortadas

%ordfilt2(Icropped,5,ones(15,15))
% Disco óptico

ICropped=imread("NoVeinsImages\image_0009.jpg");

%min(ICropped(:))%las imagenes con la retina al borde tienen como valor minimo 0-->cropear mas para que la segmentación vaya bien

ICroppedd=medfilt2(ICropped,[15 15]);%suavizado filtro de mediana
ISegm=imsegkmeans(ICroppedd,4);

%Closing
ElemEstrukt=strel("disk",30);
Idilate=imdilate(ISegm,ElemEstrukt);
Ierode=imerode(Idilate,ElemEstrukt);
Iclosing=Ierode;

subplot(1,3,1);imshow(ICropped,[]);
subplot(1,3,2);imshow(ISegm,[]);
subplot(1,3,3);imshow(Iclosing,[]);


% Copa óptica