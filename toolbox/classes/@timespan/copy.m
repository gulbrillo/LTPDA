% COPY makes a (deep) copy of the input TIMESPAN objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input TIMESPAN objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input timespan object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(varargin)
  
  old     = varargin{1};
  addHist = false;
  if nargin == 1
    deepcopy = true;
    addHist  = true;
  else
    deepcopy = varargin{2};
  end
  
  if deepcopy
    % Loop over input timespan objects
    new = timespan.newarray(size(old));
    obj = copy@ltpda_uoh(new, old, 1, addHist);
    
    for kk=1:numel(old)
      obj(kk).startT = copy(old(kk).startT, 1);
      obj(kk).endT   = copy(old(kk).endT, 1);
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

