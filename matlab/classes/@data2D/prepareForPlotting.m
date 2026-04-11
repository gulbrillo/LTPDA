% PREPAREFORPLOTTING takes the input data object and returns a function
% handle ready to be called on a given set of axes.
% 
% CALL
%         [f, x, y] = prepareForPlotting(data, showErrors);
%         [f, x, y] = prepareForPlotting(data, showErrors, plotfcn);
% 
% OUTPUTS:
%               f - function handle of form f(axes_handle)
%               x - the x data values that will be plotted by f
%               y - the y data values that will be plotted by f
%
% M Hewitson 2012-06-28
% 

function [f, x, y] = prepareForPlotting(varargin)
  
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
  x  = data.getX;
  y  = data.getY;
  dx = data.getDx;
  dy = data.getDy;
  
  if numel(dx) == 1
    dx = dx * ones(size(y));
  end
  
  if numel(dy) == 1
    dy = dy * ones(size(y));
  end
        
  if (isempty(dx) && isempty(dy)) || ~showErrors
    % keep the input fcn
  elseif isempty(dx)
    fcn = 'errorbar';
  else
    fcn = 'errorbarxy';
  end
  
  switch fcn
    case 'errorbar'
      f = @(ah, x, y) errorbar(ah, x, y, dy);
    case 'errorbarxy'
      f = @(ah, x, y) utils.plottools.errorbarxy(ah, x, y, dx, dy);
    otherwise
      f = str2func(fcn);
  end
  
end
