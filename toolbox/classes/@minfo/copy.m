% COPY makes a (deep) copy of the input minfo objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input minfo objects.
%
% CALL:        b = copy(a, flag)
%
% INPUTS:      a    - input minfo object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
% This is a transparent function and adds no history.
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
    % Loop over input minfo objects
    new = minfo.newarray(size(old));
    
    for kk=1:numel(old)
      new(kk).mname = old(kk).mname;
      new(kk).mclass = old(kk).mclass;
      new(kk).mpackage = old(kk).mpackage;
      new(kk).mcategory = old(kk).mcategory;
      new(kk).mversion = old(kk).mversion;
      new(kk).description = old(kk).description;
      new(kk).children = old(kk).children;
      new(kk).sets = old(kk).sets;
      new(kk).plists = old(kk).plists;
      new(kk).argsmin = old(kk).argsmin;
      new(kk).argsmax = old(kk).argsmax;
      new(kk).outmin = old(kk).outmin;
      new(kk).outmax = old(kk).outmax;
      new(kk).modifier = old(kk).modifier;
    end
  else
    new = old;
  end
  
  varargout{1} = new;
end

