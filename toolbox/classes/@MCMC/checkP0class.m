% checkP0class
%  
% A utility function that checks the class of the input parameters. If it
% is a pest objects, the parameter names and values are being ectracted
% from it. Otherwise errors are thrown.
%
% NK 2015
%
function [p0, paramNames] = checkP0class(varargin)
  
  if nargin == 1
    p0 = varargin{1};
  elseif nargin == 2
    p0 = varargin{1};
    paramNames = varargin{2};
  end
    
  % Check if is a pest object and get the names and values from it
  if isa(p0, 'pest');
    fprintf('* A pest object has been introduced. The parameter names will be extracted from it... \n')
    paramNames = p0.names;
  else
    % Define parameter names
    if isempty(paramNames)
      warning('### The parameters ''params'' names filed is empty. A generic array of names will be generated...');
      paramNames = getParamNames(p0);
    end
  end
  
end

%
% GetParamNames function
%
function names = getParamNames(xo)
  xo    = double(xo);
  names = cell(1, numel(xo));
  for ii=1:numel(xo)
    names{ii} = sprintf('p%d',ii);
  end
end