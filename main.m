function main
tStart=tic;
figure(1);
imhist1('butterfly.bmp');   %调用直方图画图函数
figure(2);
GlobalHistogramEqualization('butterfly.bmp');%调用全局直方图均衡化函数
figure(3);
LocalHistogramEqualization('butterfly.bmp');%调用局部直方图均衡化函数
figure(4);
DynamicHistogramEqualization('butterfly_noisy.bmp');%调用动态直方图均衡化函数
figure(5);
DynamicHistogramEqualization('brain.bmp');%调用动态直方图均衡化函数
 tEnd=toc(tStart);
 fprintf('总共花费时间：%.4fs\n',tEnd);