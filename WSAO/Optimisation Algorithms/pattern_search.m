classdef pattern_search < handle
  properties
    number_dimensions     % number of dimensions to solve.
    search_points         % cost sample points around centre point.
    position              % current position of centroid as column vector.
    position_cost;        % cost value at current position.
    cost_function         % returns cost as function of position.
    eval_function         % returns # of evals as function of iteration.
    vertex_size =  0.5;    % initial length of verteces from centroid.
    shrink_rate = 0.75     % convergance rate from 0 to 1.
  end
  methods
    function obj = pattern_search(dims,costfun)
      obj.number_dimensions = dims;
      obj.cost_function = costfun;
      obj.position = zeros(dims,1);
      obj.position_cost = obj.cost_function(obj.position);
      obj.eval_function = @(i)2*dims*i + 1;
    end
    function generate_points(obj)
      positive_points = obj.vertex_size*eye(obj.number_dimensions);
      negative_points = -positive_points;
      obj.search_points = [positive_points,negative_points] + obj.position;
    end
    function step(obj)
      generate_points(obj);
      cost = zeros(2*obj.number_dimensions,1);
      for k = 1:2*obj.number_dimensions
        cost(k) = obj.cost_function(obj.search_points(:,k));
      end
      [min_search_cost,idx] = min(cost);
      if obj.position_cost <= min_search_cost
        obj.vertex_size = obj.vertex_size*obj.shrink_rate;
      else
        obj.position = obj.search_points(:,idx);
        obj.position_cost = min_search_cost;
      end
    end
    function reset_solver(obj,varargin)
      if nargin == 1
        vs = 0.5;
      else
        vs = varargin{1};
      end
      obj.position_cost = obj.cost_function(obj.position);
      obj.vertex_size = vs;
    end
  end
end