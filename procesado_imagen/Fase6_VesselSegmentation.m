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

I0=imread(ImageLocation(1,2));
I = I0(:,:,2);%For green channel extraction

%Thin vessel enhancement
sigma = 20;
Se1_size = 4;
Se2_size = 24;
Thin_TH = Optimized_tophat(Se1_size,Se2_size,I);
Thin_Hf = HomoFilt(sigma,Thin_TH);

%Thick vessel enhancement
sigma = 2;
Se1_size = 8;
Se2_size = 16;
Thick_TH = Optimized_tophat(Se1_size,Se2_size,I);
Thick_Hf = HomoFilt(sigma,Thick_TH);

Final = mat2gray(Thick_Hf + Thin_Hf);
%%
figure(1)
subplot(1,2,1);imshow(I,[]);title('Green channel')
subplot(1,2,2);imshow(Final,[]);title('Enhancement')
%%
figure(2)
subplot(1,2,1);imshow(Thin_Hf,[]);title('Thin vessel enhancement');
subplot(1,2,2);imshow(Thick_Hf,[]);title('Thick vessel enhancement');
%%

%%
function [TH] = Optimized_tophat(Se1_size,Se2_size,I)
Icomp = imcomplement(I);
Se = strel('disk',Se1_size);
Isc = imopen(Icomp,Se);
Se2 = strel('disk',Se2_size);
Ift = imclose(Isc,Se2);
TH = Icomp - Ift;
end

function [Hf] = HomoFilt(sigma,I)
Ihf = im2double(I);
Ihf  = log(1 + Ihf );
M = 2*size(Ihf ,1) + 1;
N = 2*size(Ihf ,2) + 1;
[X, Y] = meshgrid(1:N,1:M);
centerX = ceil(N/2); 
centerY = ceil(M/2); 
gaussianNumerator = (X - centerX).^2 + (Y - centerY).^2;
H = exp(-gaussianNumerator./(2*sigma.^2));
H = 1 - H; 
H = fftshift(H);
If = fft2(Ihf , M, N);
Iout = real(ifft2(H.*If));
Iout = Iout(1:size(Ihf ,1),1:size(Ihf ,2));
Ihmf = im2uint8(exp(Iout) - 1);
Hf = Ihmf;
end
%% 
% 
% 
%