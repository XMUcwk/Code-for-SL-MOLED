function [ c ] = WJGgenCircle(w,r,center)
%GENCIRCLE Summary of this function goes here
%   Detailed explanation goes here
%   w 是模板的大小
%   r 圆形模板的半径
%   center 圆心
[rr cc] = meshgrid(1:w);
c = sqrt((rr-center(1)).^2 + (cc-center(2)).^2) <= r;
end