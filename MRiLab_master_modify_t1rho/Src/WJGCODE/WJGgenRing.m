function [ c ] = WJGgenRing( w,r1,r2,center )
%GENRING Summary of this function goes here
%   Detailed explanation goes here
%   r1，r2 分别为外半径和内半径，r1应大于r2
c1 = WJGgenCircle(w,r1,center);
c2 = WJGgenCircle(w,r2,center);
c = c1 & ~c2;
end