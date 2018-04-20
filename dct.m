function features = dct(imgRGB)
%% 
% ��ͼƬ������ɫ�ռ�ת����Ȼ���ٽ��л�����������ͨ��DCTѹ����ÿ��ͼ��ȡ10�������㣬ÿ����������30ά���б�ʾ
% ���룺RBG��ɫ�ռ��ͼ
% �����30 x N ����������
patchsize = 8; % 8x8 ����
imgYBR = rgb2ycbcr(imgRGB); %��ͼƬ��RGB��ɫ�ռ�ת��YBR�ռ�

%��ÿ��ͼ����в���
[row, col] = size(imgYBR(:,:,1)); %��ȡͼƬ��С
N = ((row-8)/2)*((col-8)/2); %����ͼƬ�Ĳ�����

patches = zeros(patchsize*patchsize,3,N); %��ʼ��
D = dctmtx(8); %���������� 8x8 �� DCT�任
feature = zeros(10,3,N);  %������ʼ��
features = zeros(30,N); %������ʼ��

% ����2��λ�ò���
i=1;
for x = 1 : 2 :(row-8)
    for y = 1 : 2 :(col-8)
        for n = 1:3
            patches(:,n,i) = reshape(imgYBR(x:x+7, y:y+7,n),64,1);
        end
    i = i+1;
    end
end


%DCTά��ѹ����
for i = 1:N
    for j = 1:3
        samp = reshape(patches(:,j,i),8,8);
        comp = blkproc(samp,[8,8],'P1*x*P2',D,D');  %DCT�任,D'ΪD��ת��
        onecomp = reshape(comp,64,1); onef = onecomp([1 2 3 4 9 10 11 17 18 25]); %ÿ����ȡ���Ͻǵ�10��ֵ��Ϊ��������
        feature(:,j,i) = onef;
    end
end

% ��ÿ��ͼ�������ֵ�������õ�����ͼ�ĸ��������������
for i = 1:N
    features(:,i) = reshape(feature(:,:,i),30,1);
end





