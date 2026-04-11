% COPY makes a (deep) copy of the input mfir objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input mfir objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input mfir object
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
    % Loop over input mfir objects
    new = mfir.newarray(size(old));
    obj = copy@ltpda_filter(new, old, 1, addHist);
    
    for kk=1:numel(old)
      obj(kk).gd = old(kk).gd;
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

