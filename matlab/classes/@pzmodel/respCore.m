% RESPCORE returns the complex response of one pzmodel object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESPCORE returns the complex response of one pzmodel object
%              as a data-vector. This function should only be used by the
%              resp method of the ltpda_tf class.
%
% CALL:        r = respCore(obj, f);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = respCore(varargin)
  
  %%% Get Inputs
  obj = varargin{1};
  f   = varargin{2}; % Row vector
  
  gain  = obj.gain;
  poles = obj.poles;
  zeros = obj.zeros;
  delay = obj.delay;
  np    = numel(poles);
  nz    = numel(zeros);

  %%% Compute response
  r = gain*ones(size(f));
  
  for j=1:np
    if ~isnan(poles(j).f)
      [f, pr] = resp(poles(j),f);
      r = r .* pr;
    end
  end
  
  for j=1:nz
    if ~isnan(zeros(j).f)
      [f, zr] = resp(zeros(j),f);
      r = r ./zr;
    end
  end
  
  r = pz.resp_add_delay_core(r, f, delay);
  
end

