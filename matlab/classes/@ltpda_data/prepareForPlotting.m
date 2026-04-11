% PREPAREFORPLOTTING takes the input data object and returns quantities for
% plotting, together with a function handle ready to be called on a given
% set of axes.
% 
% CALL
%         [f, y] = prepareForPlotting(data, showErrors);
%         [f, y] = prepareForPlotting(data, showErrors, plotfcn);
% 
% OUTPUTS:
%               f - function handle of form f(axes_handle)
%               y - the y data values that will be plotted by f
% 

function [f, y] = prepareForPlotting(varargin)
  
  switch nargin
    case 2
      data = varargin{1};
      showErrors = varargin{2};
      fcn = 'plot';
    case 3
      data = varargin{1};
      showErrors = varargin{2};
      fcn = varargin{3};
    otherwise
      error('incorrect inputs');
  end
  
  % this data
  y = data.getY;
  dy = data.getDy;
  
  if numel(dy) == 1
    dy = dy(1) * ones(size(y));
  end
        
  if isempty(dy) || ~showErrors
    % keep the input fcn
  else
    fcn = 'errorbar';
  end
  
  switch fcn
    case 'errorbar'
      f = @(ah, y) errorbar(ah, y, dy);
    otherwise
      f = str2func(fcn);
  end
  
end
