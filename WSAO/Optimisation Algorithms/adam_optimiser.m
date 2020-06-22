classdef adam_optimiser < handle
  % To implement, create a for loop with  step(obj) inside it.
  % Also make sure your function hanldle takes a single column position vector
  %
  % It works by evaluating the function at some point, calculates the
  % gradient at that point by steping in each dimension and getting the
  % difference/step grad(r) = (f(r+dr)-f(r))/|dr|
  properties
    dims                % number of dimensions
    costfun             % pointer to cost function
    position            % current coordinates or position vector
    grad                % grad vector
    h = 1e-5            % step used to calculate grad = |dr|
    
    % note on h: when function measurements have 0 noise, a small h will
    % give an accurate grad estimation, however when noise is involved a
    % small h has lesser effect on the measurement than noise. One needs to
    % choose a value that will optimise accuracy and be unaffected by noise
    
    % Used to determine new position (ignore)
    V = 0
    S = 0
    Vcorr
    Scorr
    
    learningRate = 0.1  % Step scaling factor
    beta1 = 0.5         % 1st ord momentum term
    beta2 = 0.9         % 2nd ord momentum term
    epsilon = 0.1      % Small # to avoid div by 0
    
    iteration = 0       % iteration counter
  end
  methods
    function obj = adam_optimiser(dims,fhandle)
      % object constructor. executes when user defines object
      obj.dims = dims;
      obj.costfun = fhandle;
      obj.position = zeros(dims,1); % starting from origin
      %obj.position = 0.02*randn(dims,1);
    end
    function getGrad(obj)
      % calculates grad vec, see function description
      finalCost = zeros(obj.dims,1); % preallocating cost in other directions
      initialCost = obj.costfun(obj.position); % measuring f(r) at current pos
      H = eye(obj.dims) * obj.h; % H = [dr1 dr2 ... dr_n] -> dr = n×1 vector
      % eye(n) = n×n identity matrix.
      for i = 1:obj.dims
        newPos = obj.position + H(:,i); % H(:,i) = dr_i (see comment above)
        finalCost(i) = obj.costfun(newPos); % cost_i = f(r+dr_i)
      end
      obj.grad = (finalCost-initialCost)/obj.h;
    end
    function step(obj)
      obj.iteration = obj.iteration + 1;
      getGrad(obj);
      % fancy stuff to calculate best direction to move in
      obj.V = obj.beta1*obj.V + (1-obj.beta1)*obj.grad;
      obj.S = obj.beta2*obj.S + (1-obj.beta2)*obj.grad.^2;
      obj.Vcorr = obj.V/(1-obj.beta2^obj.iteration);
      obj.Scorr = obj.S/(1-obj.beta2^obj.iteration);
      obj.position = obj.position - obj.learningRate*(obj.Vcorr./sqrt(obj.Scorr + obj.epsilon));
      idx1 = obj.position < -1;
      idx2 = obj.position > 1;
      obj.position(idx1) = -1;
      obj.position(idx2) = 1;
    end
    function reset_solver(obj)
      obj.position(:) = 0;
      obj.V = 0;
      obj.S = 0;
      obj.iteration = 0;
    end
    function settings(obj,varargin)
        % Set solver settings, eg. obj.settings(0.1,[],0.2).
        % Index is as follows. 1.learningRate, 2.beta1, 3.beta2.
        % Read object properties
        prop_array = [
            obj.learningRate;
            obj.beta1;
            obj.beta2;
            obj.h;
            ];
        % Check for non-empty elements. Non-empty: idx = 1. Else 0
        idx = ~cellfun(@isempty,varargin);
        for i = 1:nargin-1
            % If not empty, overwrite
            if idx(i)
                prop_array(i) = varargin{i};
            end
        end
        % Change properties
        obj.learningRate	= prop_array(1);
        obj.beta1           = prop_array(2);
        obj.beta2           = prop_array(3);
        obj.h               = prop_array(4);
    end
  end
end