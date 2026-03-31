% SUMMARYREPORT generates an HTML report about the inner objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUMMARYREPORT generates an HTML report about the inner
%              objects.
%
% The input objects are grouped by data type, and one table is generated
% per data type, with each row of each table representing an object.
% 
% CALL:        summaryReport(objs);
%              summaryReport(objs, options);
%
% INPUTS:      objs    - LTPDA objects
%              options - a plist of options
%
% PARAMETERS:
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'summaryReport')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = summaryReport(varargin)

  % starting initial checks
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all objs and plists
  [cs, c_invars] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  
  pages = {};
  for kk=1:numel(cs)    
    objs = cs(kk).getObjectsOfClass('ao');
    pages = [pages {objs.summaryReport(plist('title', cs(kk).name))}];    
  end

  if nargout == 1
    varargout{1} = pages;
  else    
    for kk=1:numel(pages)
      html = ['text://' pages{kk}];      
      web(html, '-new');
    end    
  end

end

%--------------------------------------------------------------------------
% Get Info
%
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pls = getDefaultPlist(sets{1});
  else
    sets = {'Default'};
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pls);
  ii.setModifier(false);
  ii.setOutmin(0);
end

function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function plo = buildplist(set)
  switch lower(set)
    case 'default'
      
      plo = plist();
      
      % title
      p = param({'title', 'A title for the report.'}, paramValue.EMPTY_STRING);
      plo.append(p);
      
    otherwise
      error('### Unknown parameter set [%s].', set);
  end
end

