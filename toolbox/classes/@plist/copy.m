% COPY makes a (deep) copy of the input plist objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input plist objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input plist object
%              flag - true: make a deep copy, false: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(varargin)
  
  old     = varargin{1};
  if nargin == 1
    deepcopy = true;
  else
    deepcopy = varargin{2};
  end
  
  if deepcopy
    % Loop over input plist objects
    new = plist.newarray(size(old));
    obj = copy@ltpda_uo(new, old, true);
    
    for kk = 1:numel(old)
      if ~isempty(old(kk).params)
        obj(kk).params  = copy(old(kk).params, true);
      end
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

