classdef FarField < handle
    properties
        image
        wavefront
        near_field
        ideal_farfield
        phase_gain    = 1
        aperture_size = 0.2   % final size = initial size / aperture_size
        noise_dev     = 0.05  % Range of noise as % of max value
        noise_mean    = 0.05  % Background value as % of max value
    end
    methods
        function varargout = generate_farfield(obj,nf,wf)
            rows = size(wf,1);
            cols  = size(wf,2);
            if isscalar(nf)
                nf = ones(rows,cols)*nf;
            end
            % Calculating padding amount from apert_size and then padding
            sz2 = [rows,cols] / obj.aperture_size;
            padwidth = floor(sz2-[rows,cols])/2;
            padded_nf = padarray(nf,padwidth,0,'both');
            padded_wf = padarray(wf,padwidth,0,'both');
            % Calculating farfield image
            pupil = padded_nf.*exp(1i.*padded_wf.*obj.phase_gain);
            %pupil = gpuArray(pupil);
            obj.image = fftshift(fft2(pupil,sz2(1),sz2(2)));
            obj.image = obj.image.*conj(obj.image);
            % Cropping to remove extra space created by padding
            obj.image = obj.image(padwidth(1)+1:end-padwidth(1),...
                padwidth(2)+1:end-padwidth(2));
            % Adding gaussian noise to image, simulating a real camera
            deviation = obj.noise_dev*max(obj.image,[],'all')/8;
            mean = obj.noise_mean*max(obj.image,[],'all');
            obj.image = obj.image + deviation*randn(rows,cols) + mean;
            
            %obj.image = gather(obj.image);
            
            obj.wavefront = wf;
            obj.near_field = nf;
            
            if nargout == 1
                varargout{1} = obj.image;
            end
        end
        function settings(obj,varargin)
            % Set simmulation settings, eg. obj.settings(0.1,[],0.2,0.3).
            % Index is as follows. 1.phase_gain, 2.aperture_size,
            % 3.noise_dev, 4.noise_mean
            % Read object properties
            prop_array = [
                obj.phase_gain;
                obj.aperture_size;
                obj.noise_dev;
                obj.noise_mean
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
            obj.phase_gain      = prop_array(1);
            obj.aperture_size   = prop_array(2);
            obj.noise_dev       = prop_array(3);
            obj.noise_mean      = prop_array(4);
        end
    end
end

