function [image_out]=pcaEnhance(I,plot)

mask = im2bw(I,40/255);
se = strel('diamond',20);               %str. element of dimond type of size 20 (errosion)
erodedmask = im2uint8(imerode(mask,se));    %erroded img

%����PCA��ǿ���㷨?
%ת����lab�ռ�
lab = rgb2lab(im2double(I));
lab(:,:,2)=0;lab(:,:,3)=0;
wlab = reshape(lab,[],3);%������
[C,S] = pca(wlab); %���ɷַ���
S = reshape(S,size(lab));%SΪPCA���������µľ���
S = S(:,:,1);
gray = (S-min(S(:)))./(max(S(:))-min(S(:)));%��һ��?
J = adapthisteq(gray,'numTiles',[8 8],'nBins',256); %CLAHEֱ��ͼ����
h = fspecial('average', [11 11]);%����ƽ���˲�����
JF = imfilter(J, h);%�˲�����
Z = imsubtract(JF, J);% ȡ�Ҷ�ͼ����ƽ���˲��Ĳ�ֵ
level = graythresh(Z);%�ҵ�ͼƬ��һ�����ʵ���ֵ??
BW = imbinarize(Z, level-0.008);%�Ҷ�ͼתΪ������
BW2 = bwareaopen(BW, 50);%ɾ����ֵͼ��BW�����С��50�Ķ���?
image_out=BW2.*(erodedmask==255);
if plot==true
    %CLAHE��JF
    %CLAHE�˲����ֵ��Z
    %�����image_out
    figure();
    subplot(221),imshow(gray),title('PCA���һ��');
    subplot(222),imshow(JF),title('CLAHE���ֵ�˲�');
    subplot(223),imshow(Z),title('CLAHE���ֵ�˲���ֵ');
    subplot(224),imshow(image_out),title('���ս��');
end
