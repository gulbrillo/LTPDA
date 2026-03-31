% CHAR overloads char() function for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR overloads char() function for analysis objects.
%
% CALL:        c = char(ao_in);
%
% FORMAT:      c = 'ao.name/ao.data.name class(ao.data) [size(ao.data.yaxis)]'
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'char')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.OPROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  if callerIsMethod
    as = [varargin{:}];
  else
    % collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % collect all aos and plists
    as = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  end
  
  if isempty(as)
    varargout{1} = sprintf('empty AO object [%dx%d]', size(as));
   return;
  end

  % go through analysis objects
  pstr = [];
  for j=1:numel(as)
    pstr = [pstr as(j).name];
    % get data type
    if isempty(as(j).data)
      pstr = [pstr '/No data-object, '];
    else
      pstr = [pstr '/' class(as(j).data)];
      pstr = [pstr ' ' char(as(j).data) ', '];
    end
  end
  
  if pstr(end-1) == ','
    pstr = pstr(1:end-2);
  end

  varargout{1} = pstr;

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
  ii.setOutmin(0);
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

