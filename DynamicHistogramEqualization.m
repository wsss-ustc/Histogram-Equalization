function DynamicHistogramEqualization(img)
% tStart=tic;  %gap值的调节在123行
data=imread(img);%读取图像的像素值
data=data(:,:,1);

subplot(2,2,1);
imshow(data);
title('原图片');
subplot(2,2,2);
imhist(data);
title('原图片  直方图');

[m,n]=size(data);
data=data(:); %矩阵变成向量形式
allPixel=0:255; %像素点的取值是0-255
inter=double(intersect(allPixel,data));%取交集，只计算有的像素  %这里竟然要转double不然会出问题
pixelCount=zeros(256,1); %预先分配空间

for i=inter'
    pixelCount(i+1)=sum(data==allPixel(i+1));%计算每个像素点值有多少，只计算有的
end


padCount=[0
    pixelCount
    0];
for i=2:257
    pixelCount1(i-1)=sum(padCount(i-1:i+1))/3.0;  %1x3的平滑滤波消去
end

pixelCount1=round(pixelCount1);
index=find(pixelCount1~=0);   %找到其中不为0的点处
pixelStart=index(1);    %将第一个和最后一个不为0的点作为第一个和最后一个局部最小值点
pixelEnd=index(end);

part=partition(pixelStart,pixelEnd,pixelCount1);    %part对应过去的是索引，转化灰度值需要-1

flag=1;
i=1;
while flag
    [i,part,flag]=rePartition(pixelCount,part,i);  %对于每个部分的支配情况进行判断，可能需要再次进行分割
end

span(1)=part(1,2)-part(1,1);
for i=2:size(part,1)
    span(i)=part(i,2)-part(i,1)+1;
end
% for i=1:size(part,1)
%     span(i)=part(i,2)-part(i,1)+1-sum(ismember(pixelCount(part(i,1):part(i,2)),0));%这个部分是逗比的尝试部分
% end

range=span.*255./sum(span);   %进行span和range的计算

partSpan(1,1)=0;         %partSpan从0开始计数表示灰度值，而part对应过去的是索引，转化灰度值需要-1
partSpan(1,2)=range(1);  %初始化

for i=2:size(part,1)
    partSpan(i,1)=partSpan(i-1,2);
    partSpan(i,2)=partSpan(i,1)+range(i);   %进行分配区域的计算
end

partSpan=round(partSpan);
%%  这一部分是为了画出分隔符
min2=min(pixelCount);
max2=2.5*sqrt(pixelCount'*pixelCount/length(pixelCount));
tempy=min2:500:max2;
yLen=length(tempy);
hold;
for i=1:size(part,1)
    tempx=(part(i,1)-1)*ones(1,yLen);    
    plot(tempx,tempy,'-.k*');
end
tempx=(part(size(part,1),2)-1)*ones(1,yLen);    
plot(tempx,tempy,'-.k*');
%%
transFun=getTransformFunction(part,partSpan,pixelCount);   %得到对应的变换的函数

for i=1:length(data)
    data(i)=transFun(data(i)+1);  %对原图像的对应点对照变换函数进行变换，其中由于MATLAB中索引是从1开始的，需要加1
end

% tEnd=toc(tStart);
subplot(2,2,3);
imshow(reshape(data,m,n));%显示原图像
title('动态直方图均衡化后');
subplot(2,2,4);
imhist(data);
title('动态直方图均衡化后  直方图');
% fprintf('\n一共用时%.4f',tEnd);
% a=3;

function transFun=getTransformFunction(part,partSpan,pixelCount)   %计算相应像素的变换函数
transFun=zeros(1,256);   %初始化
transFun=GH(pixelCount(part(1,1):part(1,2)),part(1,1):part(1,2),partSpan(1,:),transFun);
for i=2:size(part,1)
    transFun=GH(pixelCount(part(i,1):part(i,2)),part(i,1):part(i,2),[partSpan(i,1)+1 partSpan(i,2)],transFun);
end

function transFun=GH(pixelCount,pixelIndex,partSpan,transFun)
pixelAll=sum(pixelCount);  %计算这一部分总的像素点的个数
max1=max(pixelIndex)-1;
min1=min(pixelIndex)-1;

pixelIndex1=round((pixelIndex-min1)./(max1-min1).*(partSpan(2)-partSpan(1))+partSpan(1));  %将灰度级区域变换到指定的区域

for i=1:length(pixelIndex)
    index=find(pixelIndex1<=pixelIndex1(i));    %下面一部分是为了计算CDF准备的
    count=0;
    for j=1:length(index)
        count=count+pixelCount(index(j));
    end
    transFun(pixelIndex(i))=round(count/pixelAll*(partSpan(2)-partSpan(1))+partSpan(1));  %区域进行均衡化处理
    %     temp=round((max1-min1)*sum(pixelCount(1:i))/pixelAll+min1);
    %     transFun(pixelIndex(i))=round((partSpan(2)-(partSpan(1)))*(temp-min1)/(max1-min1)+partSpan(1));
    % %     transFun(pixelIndex(i))=round((partSpan(2)-(partSpan(1)))*sum(pixelCount(1:i))/pixelAll+partSpan(1));  %获得直方图均衡的变换函数，为一向量，用sum来计算CDF(累计分布函数)
end

function part=partition(pixelStart,pixelEnd,pixelCount)   %进行第一次的分割
%pixelCount=pixelCount';
part(1,1)=pixelStart;
count=1;
winSize=1;   %检测窗口的大小 总长度为2*winSize+1
gap=5;      %局部最小值的最小幅度
padPix=padarray(pixelCount,[0,winSize]);    %扩张区域进行局部最小值检测
for i=pixelStart+1+winSize:pixelEnd-1+winSize
    if check(padPix,i,winSize,gap)  %局部最小判别的函数，方便调整      
        part(count,2)=i-winSize;
        count=count+1;
        part(count,1)=i+1-winSize;
        continue;
    end
end
% a=60;
% part(1,2)=a;
% count=count+1;
% part(count,1)=a+1;
part(count,2)=pixelEnd;

function F=check(padPix,i,winSize,gap)
F=all([padPix((i-winSize):(i-1)) padPix((i+1):(i+winSize))]>(padPix(i)+gap));%这个基本上是标准的论文的方法，后面的是我根据论文里面图片试验进行划分出来改进的结果                   %&&~(all([padPix((i-winSize):(i-1)) padPix((i+1):(i+winSize))]==(padPix(i)+gap)))
%  check1=all([padPix((i-winSize):(i-1)) padPix((i+1):(i+winSize))]>(padPix(i)+gap));
%  check2=~(all([padPix((i-winSize):(i+winSize))]==0))&&padPix(i)==0;%这里是逗比的尝试部分
%  F=check1||check2;

function [i,part,flag]=rePartition(pixelCount,part,i)   %进行再一次的区域支配情况检查
[mean,std,totalNum]=caculate((part(i,1)-1):(part(i,2)-1),pixelCount(part(i,1):part(i,2)));  %计算指定区域的均值以及标准差


if isnan(mean)   %对可能出现的特殊情况进行处理
    
    i=i+1;
    if(i>=size(part,1))  
        flag=0;
    else
        flag=1;
    end
    return;
    
else   %进行判断支配程度并相应地操作继续划分
 
    if(round(mean-std)+1>=1)
    regionCount=sum(pixelCount((round(mean-std)+1):(round(mean+std)+1)));
    else
        regionCount=sum(pixelCount(1:(round(mean+std)+1)));
    end
    if regionCount/totalNum>0.683
        i=i+1;
    else
        partTemp=zeros(size(part,1)+2,2);   %这个部分只是赋值而已的一些操作而已，就是在一个矩阵里面添加一些东西
        partTemp(1:(i-1),:)=part(1:(i-1),:);
        partTemp(i,:)=[part(i,1) round(mean-std)+1];
        partTemp(i+1,:)=[round(mean-std)+2 round(mean+std)+1];
        partTemp(i+2,:)=[round(mean+std)+2 part(i,2)];
        partTemp((i+3):end,:)= part((i+1):end,:);
        part=partTemp;
    end
    if i>=size(part,1)   %进行值边界判断
        flag=0;
    else
        flag=1;
    end
end

function [mean,std,totalNum]=caculate(num,count)   %进行计算均值以及标准差
totalNum=sum(count');
mean=sum(num.*count')/totalNum;
std=sqrt(sum(((num-mean).^2).*count')/totalNum);
