function influences = generate_influences(resolution,influence_fun,dist)
    %
    % Generates influences from actuator distribution with a given
    % resolution and influence function.
    %
    % Influence function must be a handle to a function Z(X,Y)
    % 
    % Example: Gaussian influence with circular actuator distribution
    % Note: Make sure you define the position matrix "pos_matrix"
    %       beforehand
    %
    % influence_function = @(x,y) 0.1*exp((-x.^2-y.^2)/0.1);
    % influences = generate_influences(200,influence_function,pos_matrix);
    % montage(influences)
    
    % Set up coordinate system x,y in [-1,1]
    [X,Y] = meshgrid(linspace(-1,1,resolution));
    
    % Generating influences
    channels = size(dist,2);
    influences = zeros(resolution,resolution,channels);
    
    for act_idx = 1:channels
        % Getting position of actuator from dist
        i_pos = dist(1,act_idx);
        j_pos = dist(2,act_idx);
        % Shifting X and Y coordinates
        shiftedX = X - i_pos;
        shiftedY = Y - j_pos;
        % Applying influence function
        influences(:,:,act_idx) = influence_fun(shiftedX,shiftedY);
    end
    
end