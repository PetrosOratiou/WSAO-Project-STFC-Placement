classdef ZernikeLib
    % Zernike library for generating Zernike polynomials and wavefronts
    % To save computation time, I have defined the first 36 Wyand orders of
    % the Zernike polynomials.
    %
    % % Example 1: View all the polynomials
    % polys = ZernikeLib.polys('all',200);
    % montage(polys)
    %
    % % Example 2: Find the surface reconstruction error for the first 10 orders
    % Z = ZernikeLib;
    % polys = Z.polys(1:10,100);
    % coeffs = randn(10,1);
    % surface = Z.surface(coeffs,polys);
    % predicted_coeffs = Z.moments(surface,polys);
    % predicted_surface = Z.surface(predicted_coeffs,polys);
    % RMS = sqrt(sum((surface - predicted_surface).^2,'all')/numel(surface));
    % fprintf('Reconstruction surface error: %.4f\n',RMS)
    % 
    % figure(1)
    % surf(surface);
    % shading interp
    % title('Original')
    % 
    % figure(2)
    % surf(predicted_surface)
    % shading interp
    % title('Reconstructed')
    % 
    % figure(3)
    % plot(coeffs,'k')
    % hold on
    % plot(predicted_coeffs,'.-.b')
    % hold off
    % title('Original vs Predicted')
    % xlabel('Wyant order #')
    % ylabel('Coefficient value')
    % legend({'Predicted','Original'})
    
    properties(Constant, Access = public)
        numorders = 36;
        Z = {% Zernike functions up to 36th Wyant order (evens first)
            @(r,phi) 0*r + 1;
            @(r,phi) r.*cos(phi);
            @(r,phi) r.*sin(phi);
            @(r,phi) 2*r.^2 - 1;
            @(r,phi) r.^2.*cos(2.*phi);
            @(r,phi) r.^2.*sin(2.*phi);
            @(r,phi) r.*(-2+3*r.^2).*cos(phi);
            @(r,phi) r.*(-2+3*r.^2).*sin(phi);
            @(r,phi) 1 - 6*r.^2 + 6*r.^4;
            @(r,phi) r.^3.*cos(3*phi);
            @(r,phi) r.^3.*sin(3*phi);
            @(r,phi) r.^2.*(-3 + 4*r.^2).*cos(2*phi);
            @(r,phi) r.^2.*(-3 + 4*r.^2).*sin(2*phi);
            @(r,phi) r.*(3 - 12*r.^2 + 10*r.^4).*cos(phi);
            @(r,phi) r.*(3 - 12*r.^2 + 10*r.^4).*sin(phi);
            @(r,phi) -1 + 12*r.^2 - 30*r.^4 + 20*r.^6;
            @(r,phi) r.^4.*cos(4*phi);
            @(r,phi) r.^4.*sin(4*phi);
            @(r,phi) r.^3.*(-4 + 5*r.^2).*cos(3*phi);
            @(r,phi) r.^3.*(-4 + 5*r.^2).*sin(3*phi);
            @(r,phi) r.^2.*(6 - 20*r.^2 + 15*r.^4).*cos(2*phi);
            @(r,phi) r.^2.*(6 - 20*r.^2 + 15*r.^4).*sin(2*phi);
            @(r,phi) r.*(-4 + 30*r.^2 - 60*r.^4 + 35*r.^6).*cos(phi);
            @(r,phi) r.*(-4 + 30*r.^2 - 60*r.^4 + 35*r.^6).*sin(phi);
            @(r,phi) 1 - 20*r.^2 + 90*r.^4 - 140*r.^6 + 70*r.^8;
            @(r,phi) r.^5.*cos(5*phi);
            @(r,phi) r.^5.*sin(5*phi);
            @(r,phi) r.^4.*(-5 + 6*r.^2).*cos(4*phi);
            @(r,phi) r.^4.*(-5 + 6*r.^2).*sin(4*phi);
            @(r,phi) r.^3.*(10 - 30*r.^2 + 21*r.^4).*cos(3*phi);
            @(r,phi) r.^3.*(10 - 30*r.^2 + 21*r.^4).*sin(3*phi);
            @(r,phi) r.^2.*(-10 + 60*r.^2 - 105*r.^4 + 56*r.^6).*cos(2*phi);
            @(r,phi) r.^2.*(-10 + 60*r.^2 - 105*r.^4 + 56*r.^6).*sin(2*phi);
            @(r,phi) r.*(5 - 60*r.^2 + 210*r.^4 - 280*r.^6 + 126*r.^8).*cos(phi);
            @(r,phi) r.*(5 - 60*r.^2 + 210*r.^4 - 280*r.^6 + 126*r.^8).*sin(phi);
            @(r,phi) -1 + 30*r.^2 - 210*r.^4 + 560*r.^6 - 630*r.^8 + 252*r.^10
            }
        orders = [ % Wyant indexing (evens first). orders(:,k) = [n(k);m(k)]
             0, 1, 1, 2,  2, 2,  3, 3, 4,  3, 3,  4, 4,  5, 5, 6,  4, 4,  5, 5,  6, 6,  7, 7, 8,  5, 5,  6, 6,  7, 7,  8, 8, 9,  9, 10;
             0,-1, 1, 0, -2, 2, -1, 1, 0, -3, 3, -2, 2, -1, 1, 0, -4, 4, -3, 3, -2, 2, -1, 1, 0, -5, 5, -4, 4, -3, 3, -2, 2, 1, -1,  0;
             ]
    end
    
    methods (Static)
        function [poly,x,y] = polys(ord,res)
            %
            % poly = polys(lib,ord,res)  returns polynomial of order 'ord'
            %   and resolution 'res', where 'res' is the width of x,y vectors
            %
            % [poly,x,y] = polys(lib,ord,res) Also returns the x,y vectors
            %   for plotting mainly
            %
            % ord = integer vector  returns polys of index = ord.
            % e.g.  ord = [0,4,2]   returns polynomials [Z(j=0) Z(j=4) Z(j=2)]
            %       ord = 'all'     returns all polys up to 36th order in
            %                       ascending order
            [x,y] = meshgrid(linspace(-1,1,res));
            [theta,rho] = cart2pol(x,y);
            if ischar(ord)
                if strcmp(ord,'all')
                    ord = 1:ZernikeLib.numorders;
                else
                    error('Second argument must either be numeric vector or ''all''');
                end
            end
            poly = zeros(res,res,length(ord));
            k = 1;
            for j = ord
                Z = ZernikeLib.Z{j}(rho,theta);
                Z(rho>1) = 0;
                poly(:,:,k) = Z;
                k = k + 1;
            end
            x = linspace(-1,1,res);
            y = x;
        end
        function z = surface(coeffs,arg)
            % Method to reconstruct surface from zernike coefficients.
            % Second argument can be resolution of reconstruction, or the
            % polynomials them selves. For efficieny, please create the
            % polynomials before hand and use those as the argument.
            if isscalar(arg)
                res = arg;
                orders = 1:length(coeffs);
                polys = ZernikeLib.polys(orders,res);
            else
                polys = arg;
            end
            z = 0;
            for j = 1:length(coeffs)
                z = z + coeffs(j)*polys(:,:,j);
            end
        end
        function coeffs = moments(wf,polys)
            % Resolution will increase the accuracy of the transform
            [rows,cols] = size(wf);
            if rows ~= cols
                error('Surface must be square Matrix');
            end
            N = size(polys,3);
            resol = rows;
            % Calculate dx & dy
            dx = 2/(resol-1);
            dy = 2/(resol-1);
            % Get Orders from properties
            n = ZernikeLib.orders(1,1:N)';
            m = ZernikeLib.orders(2,1:N)';
            % Calculate epsilon factor            
            epsilon = m;
            epsilon(m == 0) = 2;
            epsilon(m ~= 0) = 1;
            % Calculate integral
            integral_ = sum(wf.*polys,[2,1])*dx*dy;
            % Switch 3rd with 1st dimension
            integral_ = permute(integral_,[3,2,1]);
            % Calculate constants
            C = (2*n+2)./epsilon/pi;
            % Final result
            coeffs = C.*integral_;
        end

    end
end
