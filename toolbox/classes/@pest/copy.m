% COPY makes a (deep) copy of the input pest objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input pest objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input pest object
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
    % Loop over input pest objects
    new = pest.newarray(size(old));
    obj = copy@ltpda_uoh(new, old, 1, addHist);
    
    for kk=1:numel(old)
      
      if ~isempty(old(kk).yunits)
        obj(kk).yunits = copy(old(kk).yunits, 1);
      end
      if ~isempty(old(kk).models)
        obj(kk).models = copy(old(kk).models, 1);
      end
      
      obj(kk).y     = old(kk).y;
      obj(kk).dy    = old(kk).dy;
      obj(kk).names = old(kk).names;
      obj(kk).pdf   = old(kk).pdf;
      obj(kk).cov   = old(kk).cov;
      obj(kk).corr  = old(kk).corr;
      obj(kk).chi2  = old(kk).chi2;
      obj(kk).dof   = old(kk).dof;
      obj(kk).chain = old(kk).chain;
      
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

