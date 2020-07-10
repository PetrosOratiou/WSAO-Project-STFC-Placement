classdef simplex_optimiser < Solver
    properties
        simplex
        simplex_cost
        init_size = 0.25;
        
        r_coeff = 1
        e_coeff = 2
        c_coeff = 0.5
        s_coeff = 0.5
    end
    methods
        
        function self = simplex_optimiser(dims,costfun)
            self.dimensions = dims;
            self.cost_function = costfun;
            self.reset();
        end
        
        function reset(self)
            N = self.dimensions;
            init_position = zeros(N,1);
            nms = self.init_size*eye(N) + init_position;
            nms = cat(2,nms,init_position);
            self.simplex = nms;
            self.position = init_position;
            self.evaluations = 0;
        end
        
        function step(self,varargin)
            % See wikipedia on nelder mead simplex method for algorithm
            steps = 1;
            if ~isempty(varargin)
                steps = varargin{1};
            end
            
            for i = 1:steps
                self.sort_simplex();
                sec_to_worst_cost = self.simplex_cost(end-1);
                best_cost = self.simplex_cost(1);

                centroid = self.get_centroid();

                reflected = self.get_reflected(centroid);
                reflected_cost = self.evaluate(reflected);
                
                if reflected_cost < sec_to_worst_cost && reflected_cost >= best_cost
                    self.simplex(:,end) = reflected;
                    self.simplex_cost(end) = reflected_cost;
                elseif reflected_cost < best_cost
                    expanded = self.get_expanded(centroid,reflected);
                    expanded_cost = self.evaluate(expanded);
                    if expanded_cost < reflected_cost
                        self.simplex(:,end) = expanded;
                        self.simplex_cost(end) = expanded_cost;
                    else
                        self.simplex(:,end) = reflected;
                        self.simplex_cost(end) = reflected_cost;
                    end
                else
                    contracted = get_contracted(self,centroid);
                    contracted_cost = self.evaluate(contracted);
                    worst_cost = self.simplex_cost(end);
                    if contracted_cost < worst_cost
                        self.simplex(:,end) = contracted;
                    else
                        self.shrink_simplex();
                    end
                end
                self.position = self.simplex(:,1);
            end
        end
        
        function sort_simplex(self)
            % Sorting in ascending order: lower cost first (best < worst)
            self.simplex_cost = self.evaluate(self.simplex);
            [self.simplex_cost,idx] = sort(self.simplex_cost);
            self.simplex = self.simplex(:,idx);
        end
        
        function cost = evaluate(self,points)
            % Evaluates a single point or set of points
            % Must be N by M matrix where M is number of points
            num_points = size(points,2);
            cost = zeros(1,num_points);
            for idx = 1:num_points
                cost(idx) = self.cost_function(points(:,idx));
                self.evaluations = self.evaluations + 1;
            end
        end
        
        function centroid = get_centroid(self)
            % Centroid of all points besides worst
            centroid = mean(self.simplex(:,1:end-1),2);
        end
        
        function reflected = get_reflected(self,centroid)
            % Reflection of worst from the centroid
            worst = self.simplex(:,end);
            reflected = centroid + self.r_coeff*(centroid-worst);
        end
        
        function expanded = get_expanded(self,centroid,reflected)
            % Expanding reflected point
            expanded = centroid + self.e_coeff*(reflected-centroid);
        end
        
        function contracted = get_contracted(self,centroid)
            % Contraction. Point between worst & centroid
            worst = self.simplex(:,end);
            contracted = centroid + self.c_coeff*(worst - centroid);
        end
        
        function shrink_simplex(self)
            best = self.simplex(:,1);
            for i = 2:self.dimensions
                current = self.simplex(:,i);
                current = best + self.s_coeff*(current - best);
                self.simplex(:,i) = current;
            end
        end
        
        function settings(self,varargin)
            prop_array = [
                self.init_size;
                self.r_coeff;
                self.e_coeff;
                self.c_coeff;
                self.s_coeff;
                ];
            idx = ~cellfun(@isempty,varargin);
            for i = 1:nargin-1
                if idx(i)
                    prop_array(i) = varargin{i};
                end
            end
            self.init_size = prop_array(1);
            self.r_coeff = prop_array(2);
            self.e_coeff = prop_array(3);
            self.c_coeff = prop_array(4);
            self.s_coeff = prop_array(5);
        end
        
    end
end