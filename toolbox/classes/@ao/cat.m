% CAT concatenate AOs into a row vector.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CAT concatenate AOs into a row vector.
%
% CALL:        a = cat(a1, a2)
%
% REMARK:      This method is a transparent method, and doesn't add history.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'cat')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cat(varargin)

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

  % Collect all AOs and plists
  as  = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Reshape always to a row vector
  bs = reshape(bs, 1, []);

  % Set output
  if nargout == 0
    error('### cat cannot be used as a modifier. Please give an output variable.');
  else
    varargout{1} = bs;
  end
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
  ii.setModifier(false);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl_default = buildplist()
  pl_default = plist.EMPTY_PLIST;
end


