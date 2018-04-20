function features = dct(imgRGB)
%% 
% 对图片进行颜色空间转换，然后再进行滑动采样，在通过DCT压缩，每个图层取10个特征点，每个采样块用30维的列表示
% 输入：RBG颜色空间的图
% 输出：30 x N 的特征数据
patchsize = 8; % 8x8 窗口
imgYBR = rgb2ycbcr(imgRGB); %将图片从RGB颜色空间转到YBR空间

%对每个图层进行采样
[row, col] = size(imgYBR(:,:,1)); %获取图片大小
N = ((row-8)/2)*((col-8)/2); %计算图片的采样数

patches = zeros(patchsize*patchsize,3,N); %初始化
D = dctmtx(8); %常矩阵，用于 8x8 的 DCT变换
feature = zeros(10,3,N);  %特征初始化
features = zeros(30,N); %特征初始化

% 滑动2个位置采样
i=1;
for x = 1 : 2 :(row-8)
    for y = 1 : 2 :(col-8)
        for n = 1:3
            patches(:,n,i) = reshape(imgYBR(x:x+7, y:y+7,n),64,1);
        end
    i = i+1;
    end
end


%DCT维度压缩，
for i = 1:N
    for j = 1:3
        samp = reshape(patches(:,j,i),8,8);
        comp = blkproc(samp,[8,8],'P1*x*P2',D,D');  %DCT变换,D'为D的转置
        onecomp = reshape(comp,64,1); onef = onecomp([1 2 3 4 9 10 11 17 18 25]); %每层提取左上角的10个值作为特征向量
        feature(:,j,i) = onef;
    end
end

% 将每层图像的特征值简单相连得到单张图的各区域的特征向量
for i = 1:N
    features(:,i) = reshape(feature(:,:,i),30,1);
end





