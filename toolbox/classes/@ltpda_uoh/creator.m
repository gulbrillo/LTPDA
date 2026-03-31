% CREATOR Extract the creator(s) from the history.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Extract the creator(s) from the history.
%
% CALL:        string = creator(obj)
%              cell   = creator(obj, 'ALL')
%              cell   = creator(obj, pl)
%
% OPTIONS:     'ALL': Return all persons which modified the object
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'creator')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = creator(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  %%% Check number of inputs
  if nargin > 2
    error('### Unknown number of inputs');
  end

  %%% Get the input object
  if ~isa(varargin{1}, 'ltpda_uo')
    error('### The first input must be a user object.')
  else
    objs = varargin{1};
  end

  %%% Get the option from the second input
  option = '';
  if nargin == 2
    if isa(varargin{2}, 'plist')
      option = find_core(varargin{2}, 'option');
    else
      option = varargin{2};
    end
  end

  %%% Check that the option works only for one object.
  if numel(objs) > 1 && strcmpi(option, 'all')
    error('### The option ''all'' works only for one object');
  end

  out = {};
  if isempty(option)
    for ii = 1:numel(objs)
      if ~isempty(objs(ii).hist)
        out = [out objs(ii).hist.creator.creator];
      end
    end
  elseif strcmpi(option, 'all')
    out = getCreator({}, objs.hist);
    out = unique(out);
  else
    error('### Unknown option [%s]', option);
  end

  %%% Set output
  if numel(out) <= 1
    %%% if the output contains only one creator then return a string and
    %%% not a cell array.
    out = char(out);
  end
  varargout{1} = out;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getCreator
%
% DESCRIPTION: Get all creators from the history
%
% HISTORY:     10-12-2008 Diepholz
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function creators = getCreator(creators, h)
  for ii = 1:numel(h)
    creators = getCreator([creators, h(ii).creator.creator], h(ii).inhists);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     10-12-2008 Diepholz
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     10-12-2008 Diepholz
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist('option', '');
end

