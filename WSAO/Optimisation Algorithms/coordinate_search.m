classdef coordinate_search < Solver
    properties
        sMatrix
        srange
        origin
        samples = 5;
    end
    
    methods
        function self = coordinate_search(dim,fhandle,varargin)
            if nargin == 3
                self.samples = varargin{1};
            end
            self.dimensions = dim;
            self.cost_function = fhandle;
            self.reset();
        end
        function reset(self,varargin)
            % Optional argument specifies initial position
            self.srange = [-ones(1,self.dimensions);ones(1,self.dimensions)];
            self.cost = inf(self.samples,1);
            if nargin == 2
                self.position = varargin{1};
            else
                self.position = zeros(self.dimensions,1);
            end
            self.origin = self.position;
        end
        function step(self)
            for i = 1:self.dimensions
                xvals = linspace(self.srange(1,i),self.srange(2,i),self.samples);
                self.sMatrix = self.origin + zeros(self.dimensions,self.samples);
                mincost = inf;
                for j = 1:self.samples
                    self.sMatrix(i,j) = xvals(j);
                    self.cost(j) = self.cost_function(self.sMatrix(:,j));
                    self.evaluations = self.evaluations + 1;
                    if self.cost(j) <= mincost
                        mincost = self.cost(j);
                        idx = j;
                    end
                end
                self.position = self.sMatrix(:,idx);
                if idx == 1 || idx == self.samples
                    self.srange = self.srange + (self.position' - self.origin');
                else
                    self.srange(1,i) = self.sMatrix(i,idx-1);
                    self.srange(2,i) = self.sMatrix(i,idx+1);
                end
                self.origin = self.position;
            end
        end
    end
end