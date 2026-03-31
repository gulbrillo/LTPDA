% LCOHERE estimates the coherence between elements of the vector using
% a log-spaced frequency axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LCOHERE estimates the coherence between the elements of the 
%              vector input on a log-spaced frequency axis. The elements
%              are expected to be time-series AOs, otherwise an error will
%              occur.
%
% The input should be a vector of time-series AOs of length N. LCOHERE will
% then compute all coherences between the elements of the
% vector, resulting in a symmetric matrix of size NxN. 
% 
% 
% CALL:        mo = ltfe(mi, pl)
%
% INPUTS:      mi   - input matrix object of size Nx1 (or 1xN)
%              pl   - input parameter list
%
% OUTPUTS:     mo   - output matrix object of size NxN
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'lcohere')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lcohere(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);


  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all matrix objects
  [ms, m_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % compute lcohere
  mout = xspec(ms, 'lcohere', pl);

  % add history
  mout.addHistory(getInfo('None'), pl, m_invars, ms.hist);
  
  % Set output
  varargout{1} = mout;

end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(1);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  % General plist for Welch-based, linearly spaced spectral estimators
  pl = plist.LPSD_PLIST;
  
end

