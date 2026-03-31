% RESPCORE returns the complex response of one miir or mfir object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESPCORE returns the complex response of one miir or mfir
%              object as a data-vector. This function should only be used
%              by the resp method of the ltpda_tf class.
%
% CALL:        r = respCore(obj, f);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = respCore(varargin)
  
  %%% Get Inputs
  obj = varargin{1};
  f   = varargin{2}; % Row vector
  
  ndata = numel(f);
  
  %%% compute Laplace vector
  s = -1i.*2*pi.*f;
  % Check the sample rate
  if isempty(obj.fs),
    fs = 1;
  else
    fs = obj.fs;
  end
  
  %%% Compute filter response
  num = zeros(1, ndata);
  for n=1:length(obj.a)
    num = num + obj.a(n).*exp(s.*(n-1)/fs);
  end
  if obj.isprop('b')
    denom = zeros(1, ndata);
    for n=1:length(obj.b)
      denom = denom + obj.b(n).*exp(s.*(n-1)/fs);
    end
    r = num ./ denom;
  else
    r = num;
  end
  
end

