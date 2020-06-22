function quality = strehl(ideal,aberrated)
    quality = get_volume(aberrated./ideal,[0 1],[0 1]);
end

function vol = get_volume(f,xlim,ylim)
    [h,w] = size(f);
    
    a = xlim(1);
    b = xlim(2);
    c = ylim(1);
    d = ylim(2);
    
    vol = (b-a)*(d-c)/h/w * sum(f,'all');
end