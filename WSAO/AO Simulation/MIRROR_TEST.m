%% Either create your own mirror or load from existing configs
% Do not run both section, or the second mirror will overwrite the first
% Run either and then the 3rd section
%
% The program generates a random wavefront. Then it tres to fit the mirror
% surface to it, by finding the optimum voltages that minimise the error 
% between them, using an gradient descent.
% A good mirror should be able to flatten (fit) a wavefront to a reasonable degree.
% Note that coefficients of every order are equally likely to be high,
% whereas in reality lower orders are usually higher in value. Testing
% a few times should give you an idea of the mirror performance for orders
% up to the maximum order defined at the beging of the 3rd section
%=================================================================================%

%% Run this section for New mirror
% 
[~, mirror] = MirrorMaker;
% 
% %% Run this section to load from file
% load('Mirror presets\new_square','influences');
% mirror = mirror_model(influences);
%% 3rd Section

%mirror = mirror_model(36,100,0.2);
% rng(21)   % Keep same wavefront (for testing different mirros/parameters)
channels = mirror.channels;

resolution = 100;
orders = 36;
crop_amt = 15; % cropping in each side

% Cropping polynomials to remove "pulling effect at the edges"
uncropped_polys = leg_polys(orders,resolution+2*crop_amt);
polys = zeros(resolution,resolution,orders);
for i = 1:orders
    polys(:,:,i) = crop_matrix(uncropped_polys(:,:,i),crop_amt);
end
coeffmag = nan(100,1);
for idx = 1:1
    coeffs = 2*randn(orders,1);
    initwf = coeff_surface(coeffs,polys);

    fhandle = @(pos) cost_function(pos,initwf,mirror);
    solver = gdm_solver(channels,fhandle);
    solver.gradstep = 0.05;
    solver.momentum = 0.8;
    coeffmag(idx) = norm(coeffs);
    figure(1)

    subplot(2,2,1)
    surf(initwf)
    shading interp
    %lims = [min(initwf,[],'all') max(initwf,[],'all')];
    lims = [-6 6];
    title("WF to be corrected")
    zlim([lims(1) lims(2)])

    iterations = 60;
    cost = nan(iterations,1);
    for i = 1:iterations
        solver.step();
        volts = solver.position*100;
        mirror.set_channels(volts);
        outwf = initwf - mirror.shape;

        cost(i) = sqrt(sum(outwf(:).^2)/numel(outwf));
        
        subplot(2,2,2)
        surf(outwf)
        shading interp
        zlim([lims(1) lims(2)])
        title("Corrected WF")
        
        subplot(2,2,3)
        surf(mirror.shape)
        shading interp
        zlim([lims(1) lims(2)])
        title("Mirror Shape fitted")
        
        subplot(2,2,4)
        plot(cost,'b')
        zlim([lims(1) lims(2)])
        title("Cost function (RMS)")
        xlabel("Iteration")
        ylabel("Cost")
        
        drawnow
    end
    fprintf("%.4f\n", cost(end))
end

function cost = cost_function(pos,initwf,mirror)
    volts = pos*100;
    mirror.set_channels(volts);
    outwf = initwf - mirror.shape;
    cost = sqrt(sum(outwf(:).^2)/numel(outwf));
end
