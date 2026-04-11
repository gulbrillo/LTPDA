% COPY makes a (deep) copy of the input mfh objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input mfh objects.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input mfh object
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
    new = mfh.newarray(size(old));
    obj = copy@ltpda_uoh(new, old, 1, addHist);
    
    for kk=1:numel(old)
      obj(kk).func = old(kk).func;
      obj(kk).inputs = old(kk).inputs;
      obj(kk).constants = old(kk).constants;
      
      if ~isempty(old(kk).paramsDef)
        obj(kk).paramsDef = copy(old(kk).paramsDef, 1);
      end
      obj(kk).funcDef   = old(kk).funcDef;
      obj(kk).numeric   = old(kk).numeric;

      obj(kk).constObjects = copyCellArray(old(kk).constObjects);
      obj(kk).inputObjects = copyCellArray(old(kk).inputObjects);
      
      if ~isempty(old(kk).subfuncs)
        obj(kk).subfuncs = copy(old(kk).subfuncs, 1);
      end
      
    end
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

function out = copyCellArray(vals)
  out = {};
  for oo=1:numel(vals)
    if isa(vals{oo}, 'ltpda_uo')
      out{oo} = copy(vals{oo}, 1);
    else
      out{oo} = vals{oo};
    end
  end
end


