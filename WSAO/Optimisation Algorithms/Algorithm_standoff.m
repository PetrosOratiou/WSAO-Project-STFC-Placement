global calls
calls = 0

xlims = [-5 5];
ylims = [-5 5];
resol = 100;

fhandle = @(r)f(5*r);
solver = simplex_optimiser(2,fhandle);
%solver.settings(0.001,0.9,[],[]); % (0.0008,0.95,[],[])

iters = 600;
cost = zeros(iters,1);
for i = 1:iters
    solver.step()
    pos = 5*solver.position;
    cost(i) = debugf(pos);
    
    drawnow
end

figure(2)
plot(cost)

name = class(solver);
Data.(name).cost = cost;  % C_name = cost
Data.(name).evals = calls; % E_name = evals
Data.(name).pos = pos;   % P_name = final position

function z = f(r)
    global calls
    calls = calls + 1;
    N = length(r);
    %z = (x.^2 + y - 11).^2 + (x + y.^2 - 7).^2;    % 4 local minima
    %z = (1 - x).^2 + 100*(y - x.^2).^2; % Rosenbrock function
    z = 0;
    for i = 1:N-1
        z = z + 100*(r(i+1)-r(i)^2)^2 + (1-r(i))^2;
    end
    
    clc
    fprintf("f calls: %i\n",calls);
end 

function z = debugf(r)
    % Same as f(r) but does not track calls
    N = length(r);
    z = 0;
    % Multidimensional Rosenbrock function
    for i = 1:N-1
        z = z + 100*(r(i+1)-r(i)^2)^2 + (1-r(i))^2;
    end
end