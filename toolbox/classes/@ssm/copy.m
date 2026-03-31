% COPY makes a (deep) copy of the input ssm objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input ssm objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input ssm object
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
    new = ssm.newarray(size(old));
    new = copy@ltpda_uoh(new, old, 1, addHist);
    
    for kk=1:numel(old)
      new(kk).amats       = old(kk).amats;
      new(kk).bmats       = old(kk).bmats;
      new(kk).cmats       = old(kk).cmats;
      new(kk).dmats       = old(kk).dmats;
      new(kk).timestep    = old(kk).timestep;
      new(kk).inputs      = copy(old(kk).inputs, 1);
      new(kk).states      = copy(old(kk).states, 1);
      new(kk).outputs     = copy(old(kk).outputs, 1);
      new(kk).params      = copy(old(kk).params, 1);
      new(kk).numparams   = copy(old(kk).numparams, 1);
    end
  else
    new = old;
  end
  varargout{1} = new;
  
end


