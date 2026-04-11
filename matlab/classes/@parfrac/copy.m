% COPY makes a (deep) copy of the input parfrac objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input parfrac objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input parfrac object
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
    % Loop over input parfrac objects
    new = parfrac.newarray(size(old));
    obj = copy@ltpda_tf(new, old, 1, addHist);
    
    for kk=1:numel(old)
      obj(kk).res    = old(kk).res;
      obj(kk).poles  = old(kk).poles;
      obj(kk).pmul   = old(kk).pmul;
      obj(kk).dir    = old(kk).dir;
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

