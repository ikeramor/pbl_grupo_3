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


MalCorte=[145, 99, 89, 74, 66, 62, 43, 28, 19, 5];
MalCorte=sort(MalCorte,'descend');

for i=1:length(MalCorte)
num=MalCorte(1,i);
T(num,:)=[];
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

% Ubicación de las imagenes sin vasos
NVImagePath=fullfile('NoVeinsImages');
NVImageLocation='';
for i=1:N
    str=string(T{i,1});
    NVImagePathFinal=fullfile(NVImagePath,str);
    NVImageLocation=[NVImageLocation,NVImagePathFinal];
end
NVImageLocation=[NVImageLocation(2:end)];
%%
clc;close all;

I_V=imread(ImageLocation(1,10)); subplot(2,3,1); imshow(I_V,[]);
I_NV=imread(NVImageLocation(1,10));subplot(2,3,2);imshow(I_NV,[]);
I_NV_gray=rgb2gray(I_NV);subplot(2,3,3);imshow(I_NV_gray,[]);
I_NV_gray=imadjust(I_NV_gray);
subplot(2,3,4);imhist(I_NV_gray);

Treeshold = graythresh(I_NV_gray)*255;
Treeshold_2 = multithresh(I_NV_gray,3);

Segm=I_NV_gray>Treeshold;
Segm=bwareafilt(Segm,1);%coger el area mas grande
subplot(2,3,5);imshow(Segm,[]);

Segm_2=I_NV_gray>Treeshold_2(3);
subplot(2,3,6);imshow(Segm_2,[]);

ElemEstrukt=strel('disk',10);Segm_imp=imopen(Segm,ElemEstrukt);
ElemEstrukt=strel('disk',20);Segm_imp=imclose(Segm_imp,ElemEstrukt);%probar imfill
subplot(2,3,5);imshow(Segm_imp,[]);
%%
for i=1:N
    I_NV=imread(NVImageLocation(1,i));
    I_NV_gray=rgb2gray(I_NV);
    I_NV_gray_adj=imadjust(I_NV_gray);
    
    
    if any(I_NV_gray(:)==0) %imagenes con pixeles negros se segmentan mal, segmentar de otra manera
        Treeshold = multithresh(I_NV_gray_adj,3);
        Segm=I_NV_gray_adj>Treeshold(3);
    else
        Treeshold = multithresh(I_NV_gray_adj,4);
        Segm=I_NV_gray_adj>Treeshold(3);
 
    end
    
    ElemEstrukt=strel('disk',20);Segm=imopen(Segm,ElemEstrukt);
    Segm=bwareafilt(Segm,1);
    Segm=imfill(Segm,'holes');
    ElemEstrukt=strel('disk',120);
    Segm=imclose(Segm,ElemEstrukt);
    
    NombArchivo = string(T{i,1}); %nombre de foto dataset original
    %NombArchivo = sprintf('imagen_recortada_%d.png', i);%nombre de foto de 1 a N
    path = fullfile('SegmentacionDisco', NombArchivo);
    imwrite(Segm, path); %meter las imagenes cropeadas en una carpeta
end

SImagePath=fullfile('SegmentacionDisco');
SImageLocation='';
for i=1:N
    str=string(T{i,1});
    SImagePathFinal=fullfile(SImagePath,str);
    SImageLocation=[SImageLocation,SImagePathFinal];
end
SImageLocation=[SImageLocation(2:end)];

%% 
% 
% 
% Segmentacion
% 
% close all;
% 
% J={J_r, J_g, J_b};
% 
% treeshold=[0 125 65];
% 
% for i=1:3
% 
% subplot(4,3,i);imshow(J{i},[]);
% 
% 
% 
% w=ones(341)/341^2;
% 
% Ifilter=imfilter(I,w);
% 
% 
% 
% %Busqueda de minimos y sus cordenadas
% 
% max_intensidad=max(Ifilter(:));
% 
% [filas, columnas] = find(Ifilter == max_intensidad);
% 
% punto_central = [round(mean(filas)), round(mean(columnas))];
% 
% 
% 
% %Coordenadas centro del disco optico (Mediana de todas las coordenadas)
% 
% medianafilas=median(filas); medianacolumnas=median(columnas);
% 
% 
% 
% %Coordenadas de la esquina superior izquierda del recorte (900X900)
% 
% FilaSI = round(medianafilas - 900/2);
% 
% ColumnaSI = round(medianacolumnas - 900/2);
% 
% 
% 
% %aumentarel contraste de la imagen
% 
% %Icontraste=adapthisteq(Igreen);
% 
% 
% 
% % RealizaR el recorte (900X900)
% 
% Icropped = imcrop(J{i}, [ColumnaSI FilaSI 900-1 900-1]);
% 
% subplot(4,3,i+3);imshow(Icropped,[])
% 
% subplot(4,3,i+6);imhist(Icropped)
% 
% 
% 
% Isegm=Icropped>=treeshold(i);subplot(4,3,i+9);imshow(Isegm,[]);
% 
% end
% 
%