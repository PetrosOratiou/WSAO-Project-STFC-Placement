classdef (Abstract) Solver < handle
    % Abstract class for optimisation algorithms
    properties
        position                % Position in parameter space
        cost_function           % Function handle to objective function
        cost                    % Current cost
        dimensions              % Number of dimensions
        evaluations = 0         % Evaluations counter
    end
    methods
        pos = step(self)        % Step solver
        settings(self)          % Set solver parameters
        reset(self)             % Reset/Reinitialise solver
    end
end