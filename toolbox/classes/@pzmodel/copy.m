% COPY makes a (deep) copy of the input pzmodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input pzmodel objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input pzmodel object
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
    % Loop over input pzmodel objects
    new = pzmodel.newarray(size(old));
    obj = copy@ltpda_tf(new, old, 1, addHist);
    
    for kk=1:numel(old)
      if ~isempty(old(kk).poles)
        obj(kk).poles = copy(old(kk).poles,1);
      else
        obj(kk).poles = [];
      end
      if ~isempty(old(kk).zeros)
        obj(kk).zeros = copy(old(kk).zeros,1);
      else
        obj(kk).zeros = [];
      end
      obj(kk).gain        = old(kk).gain;
      obj(kk).delay       = old(kk).delay;
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

