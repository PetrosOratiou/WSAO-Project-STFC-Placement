classdef coordinate_search < handle
  properties
    position
    next_position
    number_dimensions
    number_samples
    cost_function
    lower_limits
    upper_limits
    position_cost = inf;
    eval_function
    samp
  end
  methods
    function obj = coordinate_search(dims,costfun,numSamples)
      obj.number_dimensions = dims;
      obj.number_samples = numSamples;
      obj.cost_function = costfun;
      obj.position  = zeros(dims,1);
      obj.next_position = zeros(dims,1);
      obj.eval_function = @(i)numSamples*dims*i;
      reset_solver(obj);
      obj.samp = cell(obj.number_samples,obj.number_dimensions);
    end
    function step(obj)
      for i = 1:obj.number_dimensions
        sample_coordinates = linspace(obj.lower_limits(i),obj.upper_limits(i),obj.number_samples);
        cost = nan(obj.number_samples,1);
        for k = 1:obj.number_samples
          temp = obj.position;
          temp(i) = sample_coordinates(k);
          cost(k) = obj.cost_function(temp);
          obj.samp{k,i} = temp;
        end
        [obj.position_cost,k] = min(cost);
        obj.next_position(i) = sample_coordinates(k);
        if k ~= 1 && k ~= obj.number_samples
          obj.lower_limits(i) = sample_coordinates(k-1);
          obj.upper_limits(i) = sample_coordinates(k+1);
        else
          offset = obj.next_position(i) - obj.position(i);
          if offset + obj.lower_limits(i) < -1
            obj.lower_limits(i) = -1;
            obj.upper_limits(i) = obj.upper_limits(i) + offset;
          elseif offset + obj.upper_limits(i) > 1
            obj.upper_limits(i) = 1;
            obj.lower_limits(i) = obj.lower_limits(i) + offset;
          else
            obj.lower_limits(i) = obj.lower_limits(i) + offset;
            obj.upper_limits(i) = obj.upper_limits(i) + offset;
          end
        end
        obj.position(i) = obj.next_position(i);
      end
    end
    function reset_solver(obj,varargin)
      if nargin == 1
        lower_limit_value = -1;
        upper_limit_value = 1;
      else
        lower_limit_value = varargin{1};
        upper_limit_value =  varargin{2};
      end
        obj.lower_limits = lower_limit_value.*ones(obj.number_dimensions,1);
        obj.upper_limits = upper_limit_value.*ones(obj.number_dimensions,1);
        obj.position  = zeros(obj.number_dimensions,1);
        obj.next_position = zeros(obj.number_dimensions,1);
        obj.position_cost = inf;
    end
  end
end