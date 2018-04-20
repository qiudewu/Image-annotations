clear all;
clc;

fprintf('开始读取样本（训练）图片~\n');
features =[];
for i=1:100
    fprintf('读取第 %d 张图片中...\n',i);
    imageName=strcat(num2str(i+999),'.jpeg');
    imgRGB = imread(imageName);
    %处理当前图像
    features = [features dct(imgRGB)];
end
% imgRGB = imread('1066.jpeg');
% fprintf('图片读取成功，采样中...\n');

%采样，压缩，提取样本特征
% features = dct(imgRGB);

fprintf('样本特征提取完成，正在训练模型...\n');
%训练模型
[label, model, llh] = EM(features,8);

fprintf('得到模型\n');