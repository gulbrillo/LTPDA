% STRING writes a command string that can be used to recreate the input object(s).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING writes a command string that can be used to recreate the
%              input object(s).
%
% CALL:        cmd = string(objs)
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'string')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)

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

  % Collect all LTPDA_UOH objects and plists
  objs = utils.helper.collect_objects(varargin(:), 'ltpda_uoh', in_names);

  % Loop over LTPDAUOH objects
  cmd = '[';
  for jj = 1:numel(objs)
    if isempty(objs(jj).hist)
      cmd = sprintf('%s%s(), ', cmd, class(objs(jj)));
    else
      if isempty(objs(jj).hist.plistUsed)
        error('### this %s was not created with a plist. Can''t convert to string.', class(objs(jj)));
      end
      if ~isempty(objs(jj).hist.inhists)
        error('### Can not run string on an object containing history. Use type() instead to rebuild objects with history.');
      end
      plstr = string(objs(jj).hist.plistUsed);
      cmd = sprintf('%s%s(%s), ', cmd, class(objs(jj)), plstr);
    end
  end
  cmd = [cmd(1:end-2) ']'];
  if strcmp(cmd, '[]')
    cmd = '';
  end

  % Set output
  varargout{1} = cmd;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
  ii.setModifier(false);
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
  pl = plist.EMPTY_PLIST;
end
% END

