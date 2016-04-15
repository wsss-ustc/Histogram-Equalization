function imhist1(img)
% tStart=tic;
% imhist(imread(img));
% tEnd=toc(tStart);
% fprintf('\n一共用时%.4f',tEnd);
% tStart=tic;
data=uint8(imread(img));%读取图像的像素值
data=data(:); %矩阵变成向量形式
axis_x=0:255; %像素点的取值是0-255
% axis_x=intersect(axis_x,data);
axis_y=zeros(256,1); %预先分配空间

for i=1:length(axis_x)
    axis_y(i)=sum(data==axis_x(i));%计算每个像素点值有多少
end

stem(axis_x,axis_y,'Marker','none');  %画出离散序列图，杆状，去除标记
xlabel('像素灰度级别','FontSize',10);
ylabel('个数','FontSize',10);   %设定x，y轴的名称

axis([0,255,min(axis_y),2.5*sqrt(axis_y'*axis_y/length(axis_y))]);%暂时写着，这个范围是设定不知为啥，不过好看不少
% tEnd=toc(tStart);
% fprintf('\n一共用时%.4f',tEnd);