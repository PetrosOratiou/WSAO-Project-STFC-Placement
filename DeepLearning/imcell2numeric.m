function Y = imcell2numeric(X)
    [r,c] = size(X{1});
    Y = cell2mat(X');
    Y = reshape(Y(:),r,c,[]);
end