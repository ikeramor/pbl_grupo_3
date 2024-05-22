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
%% 
% Eliminacion de los vasos sanguineos

I=imread(ImageLocation(1,25));
Ir=I(:,:,1);Ig=I(:,:,2);Ib=I(:,:,3);
subplot(2,2,1);imshow(Ig,[]);

ElemEstrukt=strel('disk',20);
BH=imbothat(Ig,ElemEstrukt);subplot(2,2,2);imshow(BH,[]);
BH=BH>15;
ElemEstrukt=strel('disk',5);
BH=imerode(BH,ElemEstrukt);
ElemEstrukt=strel('disk',10);
BH=imdilate(BH,ElemEstrukt);subplot(2,2,3);imshow(BH,[]);
J_g = inpaintCoherent(I,BH,'radius',30); subplot(2,2,4); imshow(J_g,[]);
%%
close all;
Ig=J_g(:,:,2);
ElemEstrukt=strel('disk',20);
BH=imbothat(Ig,ElemEstrukt);subplot(2,2,1);imshow(BH,[]);
BH=BH>15;
ElemEstrukt=strel('disk',5);
BH=imerode(BH,ElemEstrukt);
ElemEstrukt=strel('disk',10);
BH=imdilate(BH,ElemEstrukt);subplot(2,2,2);imshow(BH,[]);
J_g = inpaintCoherent(J_g,BH,'radius',30); subplot(2,2,3); imshow(J_g,[]);
%% 
%