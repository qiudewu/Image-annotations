clear all;
clc;

fprintf('��ʼ��ȡ������ѵ����ͼƬ~\n');
features =[];
for i=1:100
    fprintf('��ȡ�� %d ��ͼƬ��...\n',i);
    imageName=strcat(num2str(i+999),'.jpeg');
    imgRGB = imread(imageName);
    %����ǰͼ��
    features = [features dct(imgRGB)];
end
% imgRGB = imread('1066.jpeg');
% fprintf('ͼƬ��ȡ�ɹ���������...\n');

%������ѹ������ȡ��������
% features = dct(imgRGB);

fprintf('����������ȡ��ɣ�����ѵ��ģ��...\n');
%ѵ��ģ��
[label, model, llh] = EM(features,8);

fprintf('�õ�ģ��\n');