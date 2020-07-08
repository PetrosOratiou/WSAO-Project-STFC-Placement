opt = [0.23 0.53 -0.92]';           % optimum solution (min)
costFunction = @(r) norm(r-opt);	% handle to objective function

solver = coordinate_search(3,costFunction);

iterations = 0;
tic
while solver.cost >= 1e-5
    solver.step();
    iterations = iterations + 1;
end
pos = solver.position;

clc
fprintf("Duration:\t\t%.6f ms\n",toc*1e+3);
fprintf("Optimum:\t\t[%.5f,%.5f,%.5f]\n",opt(1),opt(2),opt(3));
fprintf("Finished at:\t[%.5f,%.5f,%.5f]\n",pos(1),pos(2),pos(3));
fprintf("Iterations:\t\t%i\n",iterations);
fprintf("Evaluations:\t%i\n",solver.evaluations);
fprintf("Final cost:\t\t%d\n",costFunction(pos));