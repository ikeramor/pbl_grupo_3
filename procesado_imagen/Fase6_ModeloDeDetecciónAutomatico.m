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

%Busqueda de maximos y sus cordenadas
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
Icropped = imcrop(I, [ColumnaSI FilaSI 900-1 900-1]);


NombArchivo = string(T{i,1}); %nombre de foto dataset original
%NombArchivo = sprintf('imagen_recortada_%d.png', i);%nombre de foto de 1 a N
path = fullfile('CroppedImages', NombArchivo);
imwrite(Icropped, path); %meter las imagenes cropeadas en una carpeta
end
%% 
% Las imagenes recortadas incorrectamente seran eliminadas y no se tendran en 
% cuenta. Estos son aproximadamente el 10%

MalCorte=[145, 99, 89, 74, 66, 62, 43, 28, 19, 5]; %78   265   350   513   755   805   883   1020   1098   1537
MalCorte=sort(MalCorte,'descend');

for i=1:length(MalCorte)
num=MalCorte(1,i);
T(num,:)=[];
end
[N, P]=size(T);%dimensiones nueva tabla
variables=T.Properties.VariableNames;
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
I_v=imread(CroppedImageLocation(1,i));Igr_v=I_v(:,:,2);%green channel

ElemEstrukt=strel('disk',20);BH=imbothat(Igr_v,ElemEstrukt);BH=BH>15;%Vessels' mask with a bottomhat
ElemEstrukt=strel('disk',5);BH=imerode(BH,ElemEstrukt);%noise removal
ElemEstrukt=strel('disk',10);BH=imdilate(BH,ElemEstrukt);%se dilata la mascara para quitar mejor las venas
NV_0 = inpaintCoherent(I_v,BH,'radius',30);%Con la mascara y la imafen original se quitan los vasos sanguineos

%Realizamos una vez mas para mejorar la eliminacion de los vasos
Ig=NV_0(:,:,2);

ElemEstrukt=strel('disk',20);BH=imbothat(Ig,ElemEstrukt);BH=BH>15;
ElemEstrukt=strel('disk',5);BH=imerode(BH,ElemEstrukt);
ElemEstrukt=strel('disk',10);BH=imdilate(BH,ElemEstrukt);
NV = inpaintCoherent(NV_0,BH,'radius',30);

NombArchivo = string(T{i,1}); 
path = fullfile('NoVeinsImages', NombArchivo);
imwrite(NV, path); %meter las imagenes nuevas en una carpeta
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
% FEATURE EXTRACTIONS
% Color moments

for i=1:N
    Ic=double(imread(ImageLocation(1,i)));
    Ic_r=Ic(:,:,1);
    Ic_g=Ic(:,:,2);
    Ic_b=Ic(:,:,3);
    %Media (mean)
    T.Media_Red(i,1)=mean(Ic_r(:));
    T.Media_Green(i,1)=mean(Ic_g(:));
    T.Media_Blue(i,1)=mean(Ic_b(:));
    %Desviación estándar (standard deviation)
    T.Desviac_Red(i,1)=std2(Ic_r);
    T.Desviac_Green(i,1)=std2(Ic_g);
    T.Desviac_Blue(i,1)=std2(Ic_b);
    %Asimetria (skewness)
    T.Asimetria_Red(i,1)=skewness(Ic_r(:));
    T.Asimetria_Green(i,1)=skewness(Ic_g(:));
    T.Asimetria_Blue(i,1)=skewness(Ic_b(:));
end
% Gray Level Covariance Matrix

%After obtaining the GLCM of an image, the different properties  are  extracted like Contrast, Correlation, Energy and  Homogeneity.
%Contrast is used to measure the variations,  Correlations measures the probability of the particular pair of  pixels  occur...
%Energy measures the uniformity and  Homogeneity measures how closely the elements are  distributed in the matrix.   
%graycomatrix
for i=1:N
    I_read=imread(ImageLocation(1,i));
    I_read_gray=rgb2gray(I_read);
    I_glcm=graycomatrix(I_read_gray);

    GrayProps=graycoprops(I_glcm);

    T.Contraste_glcm(i,1)=GrayProps.Contrast;
    T.Correlacion_glcm(i,1)=GrayProps.Correlation;
    T.Energia_glcm(i,1)=GrayProps.Energy;
    T.Homogeneidad_glcm(i,1)=GrayProps.Homogeneity;
end
% Markov Random Field Least Estimates 

%T.Contraste_glcm=[]%T.Correlacion_glcm=[]%T.Energia_glcm=[]%T.Homogeneidad_glcm=[]
% Wavelet


% Segmentación
% Disco óptico

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
    ElemEstrukt=strel('disk',250);
    Segm=imclose(Segm,ElemEstrukt);
    
    NombArchivo = string(T{i,1}); %nombre de foto dataset original
    path = fullfile('SegmentacionDisco', NombArchivo);
    imwrite(Segm, path); %meter las imagenes cropeadas en una carpeta

    T.OpticDisc_area(i,1)=sum(Segm(:));

end

SImagePath=fullfile('SegmentacionDisco');
SImageLocation='';
for i=1:N
    str=string(T{i,1});
    SImagePathFinal=fullfile(SImagePath,str);
    SImageLocation=[SImageLocation,SImagePathFinal];
end
SImageLocation=[SImageLocation(2:end)];
% Copa óptica

for i=1:N
    I_NV=imread(NVImageLocation(1,i));
    I_NV_gray=rgb2gray(I_NV);
    I_NV_gray_adj=imadjust(I_NV_gray);
    
    
    if any(I_NV_gray(:)==0) %imagenes con pixeles negros se segmentan mal, segmentar de otra manera
        Treeshold = multithresh(I_NV_gray_adj,5);
        Segm=I_NV_gray_adj>Treeshold(5);
    else
        Treeshold = multithresh(I_NV_gray_adj,4);
        Segm=I_NV_gray_adj>Treeshold(4);
    end
    
    ElemEstrukt=strel('disk',20);Segm=imopen(Segm,ElemEstrukt);
    Segm=bwareafilt(Segm,1);
    Segm=imfill(Segm,'holes');
    ElemEstrukt=strel('disk',250);
    Segm=imclose(Segm,ElemEstrukt);  

    NombArchivo = string(T{i,1}); %nombre de foto dataset original
    path = fullfile('SegmentacionCopa', NombArchivo);
    imwrite(Segm, path); %meter las imagenes cropeadas en una carpeta

    T.OpticCup_area(i,1)=sum(Segm(:));

end

SCImagePath=fullfile('SegmentacionCopa');
SCImageLocation='';
for i=1:N
    str=string(T{i,1});
    SCImagePathFinal=fullfile(SCImagePath,str);
    SCImageLocation=[SCImageLocation,SCImagePathFinal];
end
SCImageLocation=[SCImageLocation(2:end)];
% Copa y Disco

for i=1:N
    DiscoSegm=imread(SImageLocation(1,i));CopaSegm=imread(SCImageLocation(1,i));
    CopaDiscoSegm=imfuse(CopaSegm,DiscoSegm,"blend"); %blend: superponer la copa y el disco con composicion alfa 

    NombArchivo = string(T{i,1}); %nombre de foto dataset original
    path = fullfile('SegmentacionCopaDisco', NombArchivo);
    imwrite(CopaDiscoSegm, path); %meter las imagenes cropeadas en una carpeta

    disc=T.OpticDisc_area(i,1);cup=T.OpticCup_area(i,1);
    T.Ratio_DiscCup(i,1)=cup/disc;
end

SCDImagePath=fullfile('SegmentacionCopaDisco');
SCDImageLocation='';
for i=1:N
    str=string(T{i,1});
    SCDImagePathFinal=fullfile(SCImagePath,str);
    SCDImageLocation=[SCDImageLocation,SCDImagePathFinal];
end
SCDImageLocation=[SCDImageLocation(2:end)];
% MACHINE LEARNING
% Con la aplicación de MATLAB "classification learner"  se entrenaran diversos 
% modelos y se seleccionarán los que mejor predicciones hagan. La division de 
% datos se realizara por medio del metodo Cross validation (en 5 iteraciones).

%load("FineGaussianSVM.mat")
%[ypred,scores] = FineGaussianSVM.mat.predictFcn(Tunrevised);%primera predicción
%ypred
%Hacerlo con las no revisadas (TODO)