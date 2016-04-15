function LocalHistogramEqualization(img)
% tStart=tic;
data=uint8(imread(img));%读取图像的像素值
[m,n]=size(data);

subplot(2,2,1);
imshow(data);
title('原图片');
subplot(2,2,2);
imhist(data);
title('原图片  直方图');

padSize=20;  %这里的padSize主要是用作填充的大小，固定的窗口为正方形，长是奇数
%窗口长宽都为 2*padSize+1
lenn=padSize*2+1;
spatial=padarray(data,[padSize,padSize],0);%进行周边像素0填充

blockNum=lenn^2;  %提前计算block区域的总体像素点数目，由于每次固定，这里提前计算

midBlockPos=padSize+1;   %提前计算中心像素点的位置，索引时根据小块索引速度更快

LocalHist=zeros(m,n);%预先分配空间，进行存储直方图均衡化之后的图像
for i=1:m
    for j=1:n
        LocalHist(i,j)=getPixel(spatial(i:i+2*padSize,j:j+2*padSize),midBlockPos,blockNum);%调用求取这一点的像素值
    end
end
LocalHist=uint8(LocalHist);
% tEnd=toc(tStart);
% fprintf('%.4f',tEnd);
subplot(2,2,3);
imshow(LocalHist);%显示原图像
title(['局部直方图均衡化后','(窗口大小：',num2str(lenn),'*',num2str(lenn),')']);
subplot(2,2,4);
imhist(LocalHist);
title('局部直方图均衡化后  直方图');



function pixel=getPixel(block,midBlockPos,blockNum)
midPixel=block(midBlockPos,midBlockPos);   %获取需要操作的像素点的像素值
%      index=length(find(block(:)<=midPixel));
index=sum(block(:)<=midPixel);  %计数比指定点灰度值小于等于其的
pixel=round(255*index/blockNum);%取得转换之后的像素值应该为多少

%      block=sort(block(:));   %对区域内部的像素值进行排序，由此可认为为累计函数的计算方便使用
%      index=find(block==midPixel);  %找到区域中和需要修改像素相同的索引，并在之后计算取最后一个，则其索引位置及代表累计总数
%      pixel=round(255*index(end)/blockNum);  %取得转换之后的像素值应该为多少

%%下面的算法效率比较低
% [m,n]=size(spatial);
% data=spatial(:); %矩阵变成向量形式
% axis_x=0:255; %像素点的取值是0-255
% inter=intersect(axis_x,data); %取交集，只计算有的像素
% axis_y=zeros(256,1); %预先分配空间
%
% for i=inter'
%     axis_y(i+1)=sum(data==axis_x(i+1));%计算每个像素点值有多少
% end
%
% pr=axis_y./length(data);%获得对应的p(Rk),即归一化
%
% midPixel=spatial((m+1)/2,(n+1)/2)+1;
%
% pixel=round(255*sum(pr(1:midPixel)));  %获得直方图均衡的变换函数，为一向量，用sum来计算CDF(累计分布函数)

% pixel=transform(spatial((m+1)/2,(n+1)/2)+1);  %对原图像的对应点对照变换函数进行变换，其中由于MATLAB中索引是从1开始的，需要加1

