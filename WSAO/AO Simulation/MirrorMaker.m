classdef MirrorMaker < handle
    %% Notes
    %   To do: Snap to grid (is that possible?)
    %   
    %   Fixed weird wheel
    %   Loading is buggy
    properties
        %% UI properties
        FIGURE
        AXES
        moving_cursor = [nan nan] % Unused
        running = false;
        last_click = [nan nan]
        scroll_value = 0
        scroll_weight = 0.005
        
        %% Mirror Builder
        act_dist = []       % Positions of each actuator
        number_channels = 0 % Number of channels/total actuators
        influence_matrix	% Influence matrix containing influences
        influence_vector    % Influence value of each actuator
        influence_result	% Sum of all influences
        influence_function  % Equation of influence function
        resolution = 100    % Image resolution
        default_influence = 0.01	% Default inlfuence value
        mirror              % Output mirror object
    end
    
    methods
        function [self, mirror] = MirrorMaker(varargin)
            
            self.FIGURE = figure;
            msg = [
                "Undo:  CTRL+Z";
                "Clear:  DEL";
                "Add actuator:  Mouse click";
                "Change Influence:  Mouse wheel";
                "Increase/Decrease all influences:  CTRL+UP/DOWN";
                "Save configuration:  S";
                "Load configuration:  L";
                "View influences:  V"
                ];
            msgbox(msg,"Info",'help')
            %% Assigning callbacks to figure events
%             set(self.FIGURE, 'WindowButtonMotionFcn', @self.mouse_move);
            set(self.FIGURE, 'WindowScrollWheelFcn', @self.mouse_scroll);
            set(self.FIGURE, 'WindowButtonDownFcn', @self.mouse_click);
            set(self.FIGURE, 'CloseRequestFcn', @self.close_request);
            set(self.FIGURE, 'KeyPressFcn', @self.key_pressed);
            
            self.AXES = axes(self.FIGURE);
            self.AXES.XLim = [-1 1];
            self.AXES.YLim = [-1 1];
            grid(self.AXES,'on')
            self.mainLoop();
            mirror = mirror_model(self.influence_matrix);
        end
        
        function mainLoop(self)
            %% Main loop
            self.running = true;
            while self.running
                % Do stuff
                % ATM Everything is done via callbacks for efficiency
                drawnow
            end
            delete(self.FIGURE)
        end
        
        function mouse_scroll(self,~,event)
            %% Mouse scroll callback (not very smooth)
            if isempty(self.act_dist)
                return
            end
            % Get scroll amount
            if event.VerticalScrollCount > 0
                self.scroll_value = -(event.VerticalScrollAmount - 2) * self.scroll_weight;
            elseif event.VerticalScrollCount < 0
                self.scroll_value = (event.VerticalScrollAmount - 2) * self.scroll_weight;
            end
            % If value is negative or zero, do not change
            if self.scroll_value + self.influence_vector(self.number_channels) <= 1e-4
                return
            end
            self.influence_vector(self.number_channels) = self.scroll_value...
                + self.influence_vector(self.number_channels);
            % Update influences and re-plot
%             self.influence_vector(self.number_channels) = self.scroll_value + self.default_influence;
            self.update_influence()
            self.update_figure()
        end
        
        function close_request(self,~,~)
            %% Figure close callback
            self.running = false;
            delete(self.FIGURE)
        end
        
        function mouse_click(self,~,~)
            %% Mouse click callback
            self.last_click = get(self.AXES,'CurrentPoint');
            self.last_click = self.last_click(1,1:2)';
            self.number_channels = self.number_channels + 1;
            if isempty(self.influence_vector)
                self.influence_vector = self.default_influence;
            else
                self.influence_vector = cat(2,self.influence_vector,...
                    self.default_influence);
            end
            self.influence_function = @(x,y) exp((-x.^2-y.^2)/...
                self.influence_vector(self.number_channels));
            influence = generate_influences(self.resolution,...
                self.influence_function,self.last_click);
            if isempty(self.act_dist)
                self.act_dist = self.last_click;
                self.influence_matrix = influence;
            else
                self.act_dist = cat(2,self.act_dist,self.last_click);
                self.influence_matrix = cat(3,self.influence_matrix,influence);
            end
            self.influence_result = sum(self.influence_matrix,3);
            self.update_figure();
        end
        
        function update_influence(self,varargin)
            %% Updates last actuator,
            % if argument is 'all' updates all acts
            if nargin == 2
                arg = varargin{1};
                if strcmp(arg,'all')
                    for idx = 1:self.number_channels
                        self.influence_function = @(x,y) exp((-x.^2-y.^2)/...
                            self.influence_vector(idx));
                        influence = generate_influences(self.resolution,...
                            self.influence_function,...
                            self.act_dist(:,idx));
                        self.influence_matrix(:,:,idx) = influence;
                    end
                end
            else
                self.influence_function = @(x,y) exp((-x.^2-y.^2)/...
                    self.influence_vector(self.number_channels));
                influence = generate_influences(self.resolution,...
                    self.influence_function,self.act_dist(:,self.number_channels));
                self.influence_matrix(:,:,self.number_channels) = influence;
            end
            self.influence_result = sum(self.influence_matrix,3);
        end
        
        function update_figure(self)
            %% Update figure with net influence and re-set limits
            x = linspace(-1,1,self.resolution);
            contour(self.AXES, x, x, self.influence_result, 10)
            hold on
            scatter(self.AXES, self.act_dist(1,:), self.act_dist(2,:),50,'xr')
            hold off
            self.AXES.XLim = [-1 1];
            self.AXES.YLim = [-1 1];
            grid(self.AXES,'on')
        end
        
        function remove_actuator(self,index)
            %% Remove 'index' actuator
            if abs(index) > self.number_channels
                warning("Silent failure: Index error")
                return
            end
            % Emulating python indexing. -1 = end, -2 = end-1, etc.
            if index < 0
                index = self.number_channels + index + 1;
            end
            % Deleting actuator
            self.act_dist(:,index) = [];
            self.influence_matrix(:,:,index) = [];
            self.influence_vector(index) = [];
            self.number_channels = size(self.influence_vector,2);
            % If no actuators left, reset axis, do not update influences or
            % figure
            if self.number_channels == 0
                self.reset_axes();
                return
            end
            self.update_influence();
            self.update_figure();
        end
        
        function remove_all_actuators(self)
            %% Delete everything
            self.act_dist = [];
            self.influence_matrix = [];
            self.influence_vector = [];
            self.number_channels = 0;
            self.reset_axes()
        end
        
        function key_pressed(self,~,event)
            %% Key Bindings
            switch event.Key
                case 'z'    % Undo: CTRL+Z
                    if ~isempty(event.Modifier)
                        if strcmp(event.Modifier{1},'control')
                            self.remove_actuator(-1)
                        end
                    end
                case 'delete'	% Delete all actuators: DEL
                    self.remove_all_actuators
                case 'v'    % View influence Matrix
                    figure
                    montage(self.influence_matrix);
                case 'uparrow'
                    if ~isempty(event.Modifier)
                        if strcmp(event.Modifier{1},'control')
                            value = self.influence_vector + self.scroll_weight;
                            self.influence_vector = value;
                            self.update_influence('all')
                            self.update_figure();
                        end
                    end
                case 'downarrow'
                    if ~isempty(event.Modifier)
                        if strcmp(event.Modifier{1},'control')
                            value = self.influence_vector - self.scroll_weight;
                            if any(value <= 0)
                                return
                            end
                            self.influence_vector = value;
                            self.update_influence('all')
                            self.update_figure();
                        end
                    end
                case 's'    % Save config
                    self.save_mirror();
                case 'l'    % Load config
                    self.load_mirror();
                    self.update_influence('all')
                    self.update_figure();
            end
        end
        
        function save_mirror(self)
            %% Prompt for file name and save
            prompt = {'Enter file name: '};
            dlgtitle = 'Save configuration';
            dims = [1 35];
            definput = {'custom_mirror_config'};
            fname = inputdlg(prompt,dlgtitle,dims,definput);
            if isempty(fname)
                return
            end
            fname = sprintf("%s.mat",fname{1});
            distribution = self.act_dist;
            influences = self.influence_matrix;
            influence_values = self.influence_vector;
            save(fname,'distribution','influences','influence_values');
        end
        
        function load_mirror(self)
            %% Load saved file
            prompt = {'Enter file name: '};
            dlgtitle = 'Save configuration';
            dims = [1 35];
            definput = {'custom_mirror_config.mat'};
            fname = inputdlg(prompt,dlgtitle,dims,definput);
            if isempty(fname)
                return
            end
            load(fname{1},'distribution','influences','influence_values')
            self.act_dist = distribution;
            self.influence_matrix = influences;
            self.influence_vector = influence_values;
        end
        
        function reset_axes(self)
            %% Reset figure axes
            cla(self.AXES)
            self.AXES.XLim = [-1 1];
            self.AXES.YLim = [-1 1];
            grid(self.AXES,'on')
        end
    end
end