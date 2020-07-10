Solvers are given the number of dimensions and a handle to the
objective function. Objective function must be in the form 
cost = fun(colvector), where cost is a scalar.

The algorithm solves argmin(Cost(r)), given enough iterations.
However they may converge to local minima.

Example:


f = @(x,y) (x-0.123).^2 + (y+0.892).^2;   % Min at (0.123,-0.892)
fhandle = @(r) f(r(1),r(2));              % f must be in form f(r), r = [x;y]
solver_object = gdm_solver(2,fhandle);    % (substitute a child class)
solver_object.settings(0.3,0,[]);         % see class settings method

for i = 1:100
    pos = solver_object.step();
    clc
    fprintf("Position: %.3f, %.3f\n",pos(1),pos(2));
    fprintf("Iteration: %i\n",i);
    pause(0.005)
end


Licence: Do what you want