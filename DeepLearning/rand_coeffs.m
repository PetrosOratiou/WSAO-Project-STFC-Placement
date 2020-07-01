function coeffs = rand_coeffs(ords, decay)
    N = sqrt(ords);
    if N ~= round(N)
        error('N must be the square of a natural number. eg. 16,25,36,...');
    end
    [weightsR, weightsC] = meshgrid(1:N);
    weights = weightsR.^2 + weightsC.^2;
    coeffs = exp(-decay*weights) .* randn(N);
    coeffs = coeffs(:);
end
