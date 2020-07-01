function cmat = crop_matrix(mat, varargin)
% Crops matrix. eg. crop_matrix(mat,1,[1,3]) will remove 1 layer from ...
% the left edge and 1 layer from the right, as well as 1 layer from top 
% and 3 from bottom

switch nargin
    case 1
        error("Not enough input arguments")
    case 2
        yrem = varargin{1} * [1 1];
        xrem = yrem;
    case 3
        for i = 1:2
            arg = varargin{i};
            if isscalar(arg)
                arg = arg * [1 1];
            elseif iscolumn(arg)
                arg = arg';
            elseif numel(arg) > 2
                error("Argument must be 2 element vector")
            end
            varargin{i} = arg;
        end
        [yrem, xrem] = varargin{:};
    case 4
        yrem = varargin{1};
        xrem = varargin{2};
    otherwise
        error("Too many input arguments")
end

cmat = mat(1 + yrem(1) : end - yrem(2), 1 + xrem(1) : end - xrem(2));

end