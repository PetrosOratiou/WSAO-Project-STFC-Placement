classdef mirror_model < handle
    properties
        shape               % shape of mirror as resol x resol matrix
        channels            % number of channels
        voltages            % voltages vector
        influences          % influence of every actuator
        resolution          % width and height of every surface in rows & cols
        spread              % how much the influence curve spreads
        volt_const = 0.1    % default value
        custom_mirror
    end
    methods
        function obj = mirror_model(varargin)
            if nargin == 1
                obj.custom_mirror = true;
                obj.influences = varargin{1};
                obj.channels = size(obj.influences,3);
                obj.resolution = size(obj.influences,1);
                obj.spread = 'Invalid';
                return
            end
            if nargin == 3
                chan = varargin{1};
                resol = varargin{2};
                spread = varargin{3};
                % Checking inputs
                if sqrt(chan) ~= round(sqrt(chan))
                    error("Number of actuators must be the square of a natural number")
                elseif spread <= 0 || resol <= 0
                    error("Invalid resolution or spread value. Must be positive")
                end
                obj.channels = chan;
                obj.resolution = resol;
                obj.spread = spread;
            else
                error("Not enough input arguments")
            end

            generate_influences(obj);
            set_channels(obj,1);
        end
        function generate_influences(obj)
            % Default square mirror
            % Actuator placement is NxN grid such that NxN = # acts
            N = sqrt(obj.channels);
            % Create N equally spaced points in region [-1,1]
            act_positions = linspace(-1,1,N);
            % Create a meshgrid if 'resol' number of points in region [-1,1]
            [X, Y] = meshgrid(linspace(-1,1,obj.resolution));
            obj.influences = zeros(obj.resolution,obj.resolution,obj.channels);
            k = 1;
            for i_pos = act_positions
                for j_pos = act_positions
                    % Creating gaussian curve at (i_pos,j_pos)
                    obj.influences(:,:,k) = obj.gaussian(X,Y,i_pos,j_pos,1,obj.spread);
                    k = k + 1;
                end
            end
        end
        function set_channels(obj,volts)
            % Sets channels to give voltages
            if isscalar(volts)
                % For ease of use, single value means all channels
                volts = ones(obj.channels,1)*volts;
            elseif isvector(volts)
                % if vector is row, transpose to column. Needed for permute
                % later on
                if isrow(volts)
                    volts = volts';
                end
            else
                error('Argument must be a vector')
            end
            % Transforming vec from 'channels'x1 to 1x1x'channels'. Shape =
            % linear combination of all influences*volt then scaled by 
            % Vconst. Influences are of size 'resol'x'resol'x'channels'
            volts = permute(volts,[3,2,1]);
            obj.shape = obj.volt_const*sum(volts.*obj.influences,3);
            obj.voltages = permute(volts,[3,2,1]);
        end
    end
    methods (Static)
        function z = gaussian(x,y,i,j,a,c)
            % Used to generate the default influences
            z = a * exp((-(x-i).^2-(y-j).^2)/c);
        end
    end
end