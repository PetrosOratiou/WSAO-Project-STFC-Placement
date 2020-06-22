classdef gdm_solver < handle
    properties
        numdims
        costfun
        cost
        position
        momentum = 0.5
        gradient = inf
        convrate = 0.1
        gradstep = 1e-5
        L2       = 0
        
        weightedgrad = 0
    end
    methods
        function obj = gdm_solver(dims,costfun)
            obj.numdims = dims;
            obj.costfun = @(r)costfun(r) + obj.L2*sum(r.^2,'all');
            obj.position = zeros(dims,1);
        end
        function step(obj)
            obj.cost = obj.costfun(obj.position);
            pos2 = obj.gradstep*eye(obj.numdims) + obj.position;
            cost2 = zeros(obj.numdims,1);
            for i = 1:obj.numdims
                cost2(i) = obj.costfun(pos2(:,i))';
            end
            obj.gradient = (cost2-obj.cost)/obj.gradstep;
            obj.weightedgrad = obj.momentum*obj.weightedgrad +...
                (1-obj.momentum)*obj.gradient;
            obj.position = obj.position - obj.convrate*obj.weightedgrad;
        end
        function settings(obj,varargin)
            % Leave argument as [] if you don't want to change it
            % Read object properties
            prop_array = [
                obj.convrate;
                obj.momentum;
                obj.gradstep;
                obj.L2;
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
            obj.convrate = prop_array(1);
            obj.momentum = prop_array(2);
            obj.gradstep = prop_array(3);
            obj.L2       = prop_array(4);
        end
    end
end
