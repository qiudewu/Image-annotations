function [label, model, llh] = EM(data, init)
% ��˹���ģ�͵�EM�㷨
% ����: 
%   data: 30 x N ����������
%   init: k ����˹����ģ��
% Output:
%   label: 1 x N �����У�data�ķ���
%   model: ѵ���õ���ģ��
%   llh: ÿһ�صĶ�����Ȼֵ
%% ��ʼ��
tol = 1e-6;  %��������
maxiter = 500;  %����������
llh = -inf(1,maxiter);
R = initialization(data,init);
for iter = 2:maxiter
    [~,label(1,:)] = max(R,[],2);      %label��ʾ1*n���������
    R = R(:,unique(label));            % remove empty clusters��unique���label�����в��ظ���Ԫ�أ���ʾ�ǿ��������    
    model = maximization(data,R);         %EM�㷨��M step��X��ʾ���ݾ���R��ʾ������model�ǽṹ�壬��ʾģ�ͣ���������ģ�͵Ĳ���
    [R, llh(iter)] = expectation(data,model);            %EM�㷨��E step��X��ʾ���ݾ���model��ʾģ�ͽṹ�壬R��ʾ���ص������Ⱦ���llh��ʾ��Ȼ������Ŀ��ֵ
    if abs(llh(iter)-llh(iter-1)) < tol*abs(llh(iter)); break; end;
end
llh = llh(2:iter);
%%
function R = initialization(X, init)   %X�����ݾ���init���ڳ�ʼ��MoG�ĳɷ֣�R���ص���һ��n��k�еľ��󣬵�ij��Ԫ�ر�ʾ��i�������ɵ�j���ɷ����ɵĸ���
n = size(X,2);                         %n����������
if isstruct(init)  % init with a model %isstruct�ж������Ƿ���һ��matlab�ṹ��
    R  = expectation(X,init);          %���init��һ���ṹ�壬ֱ���ø�ģ�ͽ���E step
elseif numel(init) == 1                %���init��һ������
    k = init;                          %��init��ʾ��ϳɷֵĸ�������������
    label = ceil(k*rand(1,n));         %ceil�����������������ȡ������ʼ��������label
    R = full(sparse(1:n,label,1,n,k,n));              %sparseͨ����¼ϡ�����Ǹ�Ԫ�ص�������ֵ����ʡ�ڴ棬full��һ�෴���ã�R��n��k�о���n��ʾ����������k��ʾ�������ÿһ��
                                                      %��һ��one-hot��������ʾ������������һ��
elseif all(size(init)==[1,n])  % init with labels     %��init��һ��һ��n�е���������Ϊ������������
    label = init;
    k = max(label);
    R = full(sparse(1:n,label,1,n,k,n));
else
    error('ERROR: init is not valid.');
end

%% EM�㷨��E step��X��ʾ���ݾ���model��ʾģ�ͽṹ�壬R��ʾ���ص������Ⱦ���llh��ʾ��Ȼ������Ŀ��ֵ
function [R, llh] = expectation(X, model)
mu = model.mu;
Sigma = model.Sigma;
w = model.w;                           %wΪMoG�Ļ��ϵ������

n = size(X,2);                         %nΪ��������
k = size(mu,2);                        %kΪMoG��ϳɷֵĸ�������������
R = zeros(n,k);                        %R�����Ⱦ�������Ϊ��������������Ϊ����������ij��Ԫ�ر�ʾ��i�������ɵ�j���ɷ����ɵĸ���
for i = 1:k                            %����������ÿ��gauss���ʵĶ���
    R(:,i) = loggausspdf(X,mu(:,i),Sigma(:,:,i));
end
R = bsxfun(@plus,R,log(w));            %���������ȣ�δ��һ��������Ķ���
T = logsumexp(R,2);                    %��Rȡָ���Ӻ���ȡ����
llh = sum(T)/n; % loglikelihood        %��Ȼ�����ľ�ֵ
R = exp(bsxfun(@minus,R,T));           %���������Ⱦ���
%%
%EM�㷨��M step��X��ʾ���ݾ���R��ʾ�����Ⱦ��󣬵�ij��Ԫ�ر�ʾ��i�������ɵ�j���ɷ����ɵĸ��ʣ�model�ǽṹ�壬��ʾģ�ͣ���������ģ�͵Ĳ���
function model = maximization(X, R)
[d,n] = size(X);                                    %d��ʾ����ά����n��ʾ��������
k = size(R,2);                                      %k��ʾMoG�ɷֵĸ���
nk = sum(R,1);                                      %nk��ʾ�������Ⱦ���R���к�
w = nk/n;                                           %w��ʾ��ϳɷ�ϵ��               
mu = bsxfun(@times, X*R, 1./nk);                    %mu��һ��m��k�еľ��󣬱�ʾk����˹�ɷֵ�������ÿ������mԪ�������

Sigma = zeros(d,d,k);                               %Sigma��һ����ά��������ʾ��k����˹�ɷֵ�Э���������d*d��
r = sqrt(R);
for i = 1:k                                         %ѭ������ÿ���ɷֵ�Э����
    Xo = bsxfun(@minus,X,mu(:,i));
    Xo = bsxfun(@times,Xo,r(:,i)');
    Sigma(:,:,i) = Xo*Xo'/nk(i)+eye(d)*(1e-6);
end

model.mu = mu;
model.Sigma = Sigma;
model.w = w;
%% 
function y = loggausspdf(X, mu, Sigma)              %����Gauss���ʷֲ������Ķ����ĺ�������������ֱ�Ϊ����X������mu������Э����Sigma
d = size(X,1);                                      %d��ʾ����ά��
X = bsxfun(@minus,X,mu);                            %�������ֵ����
[U,p]= chol(Sigma);                                 %chol��ʾ��Э�������Sigma����һ�������Ǿ���ֽ⣬U��ʾ���������Ӿ���Sigma=U'������U��������Э�������ֽ�����ӿ����Ч�ʣ�
if p ~= 0                                           %���p��Ϊ0��Sigma�����������󣬱���
    error('ERROR: Sigma is not PD.');
end
Q = U'\X;                                           %Q=U'������X�ĳ˻�
q = dot(Q,Q,1);                                     %dot��ʾ���֮�����к�
c = d*log(2*pi)+2*sum(log(diag(U)));                
y = -(c+q)/2;
%% 
function s = logsumexp(X, dim)
% ���� log(sum(exp(X),dim))
if nargin == 1, 
    
    dim = find(size(X)~=1,1);
    if isempty(dim), dim = 1; end
end

y = max(X,[],dim);
s = y+log(sum(exp(bsxfun(@minus,X,y)),dim));  
i = isinf(y);
if any(i(:))
    s(i) = y(i);
end
%%