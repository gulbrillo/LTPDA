% RESPCORE returns the complex response of one parfrac object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESPCORE returns the complex response of one parfrac object
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

  %%% Compute response
  pfparams = struct('type', 'cont',     ...
                    'freq',  f,         ...
                    'res',   obj.res,   ...
                    'pol',   obj.poles, ...
                    'pmul',  obj.pmul,  ...
                    'dterm', obj.dir);
  pfr = utils.math.pfresp(pfparams);
  r   = reshape(pfr.resp,size(f));
  
end

