function [outMat, out_m, out_s] = transMat(x,trLv,m,s)
    
% trLv : trace level 1-normalizing

if nargin < 4, s=std(x); end
if nargin < 3, m=mean(x); end
if nargin < 2, trLv=1; end
% zero-mean
y = (x-repmat(m,size(x,1),1));

if trLv==2,
% normalizing matrix
y = y./repmat(s,size(x,1),1);
end

if trLv>2,
    y = y.*38+repmat(190,size(x,1),size(x,2));
end

outMat = y;
out_m = m;
out_s = s;
end