% COPY makes a (deep) copy of the input filterbank objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input filterbank objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input filterbank object
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
    % Loop over input filterbank objects
    new = filterbank.newarray(size(old));
    obj = copy@ltpda_uoh(new, old, 1, addHist);
    
    for kk=1:numel(old)
      if ~isempty(old(kk).filters)
        obj(kk).filters = copy(old(kk).filters,1);
      end
      obj(kk).type = old(kk).type;
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

