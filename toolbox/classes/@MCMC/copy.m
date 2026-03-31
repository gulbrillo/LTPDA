% COPY makes a (deep) copy of the input MCMCs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY makes a deep copy of the input MCMCs.
%
% CALL:        b = copy(a)
%              b = copy(a, flag)
%
% INPUTS:      a    - input analysis object
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
    new = MCMC.newarray(size(old));
    obj = copy@ltpda_algorithm(new, old, 1, addHist);
    
    for kk=1:numel(old)
      copyField(obj(kk), old(kk), 'model')
      copyField(obj(kk), old(kk), 'inputs')
      copyField(obj(kk), old(kk), 'noise')
      copyField(obj(kk), old(kk), 'covariance')
      copyField(obj(kk), old(kk), 'diffStep')
      copyField(obj(kk), old(kk), 'pest')
      copyField(obj(kk), old(kk), 'loglikelihood')
      copyField(obj(kk), old(kk), 'logParams')
      copyField(obj(kk), old(kk), 'processedModel')
      copyField(obj(kk), old(kk), 'freqs')
      copyField(obj(kk), old(kk), 'outputs')
    end
    
  else
    obj = old;
  end
  
  varargout{1} = obj;
end

function copyField(new, old, field)
  if ~isempty(old.(field))
    if isnumeric(old.(field))
      new.(field) = old.(field);
    else
      % Use LTPDA copy
      new.(field) = copy(old.(field), 1);
    end
  end
end
