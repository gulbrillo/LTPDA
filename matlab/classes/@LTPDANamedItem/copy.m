% COPY makes a (deep) copy of the input LTPDANamedItem objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input LTPDANamedItem objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input LTPDANamedItem object
%              flag - true: make a deep copy, false: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(varargin)
  
  if nargin == 1
    old      = varargin{1};
    new = LTPDANamedItem.newarray(size(old));
    deepcopy = true;
  elseif nargin == 2
    old      = varargin{1};
    deepcopy = varargin{2};    
    new = LTPDANamedItem.newarray(size(old));
  elseif nargin == 3
    new      = varargin{1};
    old      = varargin{2};
    deepcopy = varargin{3};
  else
    error('Unknown number of arguments');
  end
  
  if deepcopy
    % Loop over input plist objects
    obj = copy@ltpda_uo(new, old, true);
    
    for kk = 1:numel(old)
      if ~isempty(old(kk).units) && isa(old(kk).units, 'unit')
        obj(kk).units  = copy(old(kk).units, true);
      end
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

