% COPY makes a (deep) copy of the input smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input smodel objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input smodel object
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
    % Loop over input smodel objects
    new = smodel.newarray(size(old));
    obj = copy@ltpda_uoh(new, old, 1, addHist);
    
    for kk=1:numel(old)
      if isa(old(kk).expr, 'ltpda_obj')
        obj(kk).expr    = copy(old(kk).expr, 1);
      else
        obj(kk).expr    = old(kk).expr;
      end
      obj(kk).params  = old(kk).params;
      obj(kk).values  = old(kk).values;
      obj(kk).xvar    = old(kk).xvar;
      obj(kk).xvals   = old(kk).xvals;
      obj(kk).trans   = old(kk).trans;
      obj(kk).aliasNames   = old(kk).aliasNames;
      obj(kk).aliasValues   = old(kk).aliasValues;
      obj(kk).xunits  = copy(old(kk).xunits,1);
      obj(kk).yunits  = copy(old(kk).yunits,1);
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

