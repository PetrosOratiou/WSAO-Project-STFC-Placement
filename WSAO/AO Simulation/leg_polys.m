function polys = leg_polys(ords, resol)
    % Generates legendre polynomials up to given order
    N = sqrt(ords);
    % Check user input
    if N ~= round(N)
        error('N must be the square of a natural number. eg. 16,25,36,...');
    end
    x = linspace(-1, 1, resol)';
    Y = zeros(N,resol);
    for i = 1:N
        % inbuilt matlab function for legendre polynomials
        y = legendre(i-1,x);
        % select only first degree
        Y(i,:) = y(1,:);
    end
    polys = zeros(resol,resol,ords);
    k = 1;
    for i = 1:N
        for j = 1:N
            % Pnm(x,y) = Pn(x)*Pm(y)
            polys(:,:,k) = Y(i,:)' .* Y(j,:);
            k = k + 1;
        end
    end

end
