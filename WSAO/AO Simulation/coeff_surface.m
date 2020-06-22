function surface = coeff_surface(coeffs,polys)
    % Generates surface given the coefficients vector and polynomials
    if isrow(coeffs)
        coeffs = coeffs';
    end
    coeffs = permute(coeffs,[3,2,1]);
    surface = sum(coeffs.*polys,3);
end