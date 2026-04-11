% FITFS estimates the sample rate of the input tsdata object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Estimates the sample rate of the input data object and detects
% if the data is evenly sampled or not.
% Data can be:
%           a tsdata object, OR
%           a vector of values
% Data where any of the fluctuations in the time difference between subsequent
% samples is greater than the one due to finite numerical precision is detected
% as unevenly sampled.
%
% CALL:     fs = fitfs(obj)
%           [fs, toffset] = fitfs(obj)
%           [fs, toffset, unevenly] = fitfs(obj)
%           fs = fitfs(x)
%           [fs, toffset] = fitfs(x)
%           [fs, toffset, unevenly] = fitfs(x)
%
% INPUTS:   obj   - tsdata object
%           x     - sampling times vector
%
% OUTPUTS:  fs        - estimated sampling frequency
%           toffset   - estimated start time of the first sample (relative to the reference time)
%           unevenly  - signals whether the data is regularly sampled or not
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fs, toffset, unevenly] = fitfs(varargin)
  
  import utils.const.*
  
  switch class(varargin{1})
    case 'tsdata'
      obj = varargin{1};
      
      if isempty(obj.xaxis.data)
        % Reconstruct the informations from the object
        unevenly = false;
        fs = obj.fs;
        toff = 0;
      else
        % Call the utility to make the fit
        [fs, toff, unevenly] = tsdata.fitfs(obj.xaxis.data);
      end
      toffset = toff + obj.toffset / 1000;
      
    case {'double', 'logical'}
      % Get input vertices
      xi  = varargin{1};
      
      % Special case of an empty time-series
      if isempty(xi)
        fs = 1;
        toffset = 0;
        unevenly = false;
        return
      end
      
      % Reshape x to match with linspace output
      ss = size(xi);
      if ss(1) > ss(2)
        xi = xi.';
      end
      d = diff(xi);
      
      % Special case of just a single number time-series
      if isempty(d)
        fs = 1;
        toffset = xi(1);
        unevenly = false;
        return
      end
      
      % Initial estimate
      dt = mean(d);
      fs = 1.0 / dt;
      toffset = xi(1);
      unevenly = false;
      
      % Strict check for unevenly sampled data. This detects as unevenly
      % sampled all data where any of the fluctuations in the time
      % difference between subsequent samples is greater than the one due
      % to finite numerical precision
      maxEps = eps(norm(xi, Inf));
      if norm(d-dt, Inf) > 2*maxEps
        utils.helper.msg(msg.PROC1, 'unevenly sampled data detected');
        unevenly = true;
        
        % The median is much less sensible to outliers than the mean. It is
        % therefore a better estimate of the sampling frequency in case of
        % unevenly sampled data
        dt = median(d);
        fs = 1.0 / dt;
      end
      
    otherwise
      % Throw an error
      error('Unsupported class [%s]! Please provide data either in ''tsdata'' or ''double''', class(varargin{1}));
  end
end
