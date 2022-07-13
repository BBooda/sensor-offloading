function xI = getPercentile(x,y,p,varargin)
% y is a cumulative distribution with the bins centered at x, 
% p is the percentile (scalar between 0 and 1)

Ixequal = find(y==p);

if ~isempty(Ixequal)
    xI = x(Ixequal);
    
else
    
    Ixmin = find(y<p);
    Ixmax = find(y>=p);
    
    if isempty(Ixmin) && ~isempty(Ixmax)
        xI = 0;
        
    elseif ~isempty(Ixmin) && isempty(Ixmax)
        xI = Inf;
        
    elseif isempty(Ixmin) && isempty(Ixmax)
        xI = NaN;
        
    elseif length(Ixmin) == 1 && length(Ixmax) == 1
        Ixmin1 = Ixmin;
        Ixmax1 = Ixmax;
        x1 = x([Ixmin1,Ixmax1]);
        y1 = y([Ixmin1,Ixmax1]);
        xI = interp1(y1,x1,p,'linear');
        
    elseif length(Ixmin) == 1 && length(Ixmax) > 1
        Ixmin1 = Ixmin;
        Ixmax1 = reshape(Ixmax(1:2),1,2);
        [y1,Iyu,~] = unique(y([Ixmin1,Ixmax1]));
        x1 = x([Ixmin1,Ixmax1]);
        x1 = x1(Iyu);
        xI = interp1(y1,x1,p,'pchip');
        
    elseif length(Ixmin) > 1 && length(Ixmax) == 1
        Ixmin1 = Ixmin(end-1:end);
        Ixmax1 = Ixmax;
        [y1,Iyu,~] = unique(y([Ixmin1,Ixmax1]));
        x1 = x([Ixmin1,Ixmax1]);
        x1 = x1(Iyu);
        xI = interp1(y1,x1,p,'pchip');
        
    elseif length(Ixmin) > 1 && length(Ixmax) > 1
        Ixmin1 = Ixmin(end-1:end);
        Ixmax1 = Ixmax(1:2);
        [y1,Iyu,~] = unique(y([Ixmin1,Ixmax1]));
        x1 = x([Ixmin1,Ixmax1]);
        x1 = x1(Iyu);
        xI = interp1(y1,x1,p,'pchip');
        
    end
    
end

if length(xI)>1
    xI = xI(1);
%     warning('length(xI)>1');
end

if numel(varargin)~=0
    type = varargin{1};
    switch type
        case 'limited'
            xI(xI==Inf) = x(end);
    end
end