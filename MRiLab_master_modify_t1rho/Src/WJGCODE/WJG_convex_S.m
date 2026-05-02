function S = WJG_convex_S(w,vx,vy)
%该函数实现的功能为指定图像中多边形的顶点，返回属于该凸多边形中的所有像素点
%xv，yv为顶点坐标按照顺时针或者逆时针。vx(1) = xv(end); yv(1) = yv(end)
%输入的w是大小，vx vy是数组存的是顶点坐标。
%输出S为标签矩阵
 
row = w;
col = w;
[A,B]=meshgrid(1:row,1:col);
S = inpolygon(A,B,vy,vx);
 