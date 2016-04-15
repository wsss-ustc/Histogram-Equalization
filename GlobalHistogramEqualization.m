function GlobalHistogramEqualization(img)
% tStart=tic;
data=uint8(imread(img));%读取图像的像素值

subplot(2,2,1);
imshow(data);
title('原图片');
subplot(2,2,2);
imhist(data);
title('原图片  直方图');

[m,n]=size(data);
data=data(:); %矩阵变成向量形式
axis_x=0:255; %像素点的取值是0-255
inter=double(intersect(axis_x,data));%取交集，只计算有的像素   貌似其实取一个交集然后少算一些对比全部都计算在这种情况下的效果不太明显,可以考虑全部都算
axis_y=zeros(256,1); %预先分配空间


for i=inter'
    axis_y(i+1)=sum(data==axis_x(i+1));%计算每个像素点值有多少，只计算有的（貌似其实影响不太大，具体量大了哪个好我也没实验了）
end

pr=axis_y./length(data);%获得对应的p(Rk),即归一化

% for i=1:256
%     transform(i)=round(255*sum(pr(1:i)));  %获得直方图均衡的变换函数，为一向量，用sum来计算CDF(累计分布函数)
% end

transform=round(cumsum(pr)*255);   %为提高效率改用这个，原来使用的是上面那个算法获得直方图均衡的变换函数，为一向量，用sum来计算CDF(累计分布函数)

for i=1:length(data)
    data(i)=transform(data(i)+1);  %对原图像的对应点对照变换函数进行变换，其中由于MATLAB中索引是从1开始的，需要加1
end
% tEnd=toc(tStart);

subplot(2,2,3);
imshow(reshape(data,m,n));%显示原图像
title('全局直方图均衡化后');
subplot(2,2,4);
imhist(data);
title('全局直方图均衡化后  直方图');
% fprintf('\n一共用时%.4f',tEnd);
