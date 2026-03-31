% SUMMARYREPORT generates an HTML report about the input objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUMMARYREPORT generates an HTML report about the input
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
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [tsAOs, fsAOs, xyAOs, xyzAOs, cAOs, tfAOs] = sortObjects(as);
 
  if numel(tsAOs) ~= numel(as)
    fprintf('Will process %d time-series AOs. Other data types not currently supported.\n', numel(tsAOs));
  end
  
  % get plist
  pl = utils.helper.collect_objects(varargin(:), 'plist');
  pl = applyDefaults(getDefaultPlist('Default'), pl);

  % title
  title = pl.find('title');
  if isempty(title)
    title = 'Summary Table';
  end
  
  % create text
  str = utils.html.pageHeader(title);  
  str = [str sprintf('<h1>%s</h1>\n', title)];
  str = [str generateTSDataTable(tsAOs)];  
  str = [str utils.html.pageFooter()];
  
  if nargout == 1
    varargout{1} = str;
  else
    
    html = ['text://' str];

    web(html, '-new');
    
  end

end


function str = generateTSDataTable(tsAOs)
  
  str = '';
  str = [str sprintf('<table cellspacing="0" class="body" cellpadding="4" summary="" width="100%%" border="2">\n')];
  str = [str sprintf('<thead>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">name</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">desc</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">long desc</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">nsamples</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">nsecs</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">fs</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">dt</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">max(y)</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">min(y)</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">av(y)</th>')];
  str = [str sprintf('<th bgcolor="#D7D7D7">units</th>')];
  str = [str sprintf('</thead>\n')];

  nFiles = numel(tsAOs);
  for kk=1:nFiles
    
    fprintf('+ Processing %d of %d\n', kk, nFiles);
    try
      
      a = tsAOs(kk);
      
      % Try to get DB description
      p = MIBrowser.getParamsWithShortNames(a.name);
      if isempty(p)
        p = MIBrowser.getParamsWithIDs(a.name);
      end
      
      if isempty(p)
        shortDescription = '';
        longDescription = a.description;
      else
        shortDescription = p.shortName;
        longDescription = p.description;
      end
        
      if mod(kk,2) == 0
        color = 'F2F2F2';
      else
        color = 'FFFFFF';
      end
            
      str = [str sprintf('<tr>\n')];
      
      str = [str sprintf('<td bgcolor="#%s" align="center">%s</td>\n', color, a.name)];
      
      str = [str sprintf('<td bgcolor="#%s" align="center">%s</td>\n', color, shortDescription)];
      str = [str sprintf('<td bgcolor="#%s" align="center"  style="width:10%%">%s</td>\n', color, longDescription)];
      
      str = [str sprintf('<td bgcolor="#%s" align="center">%d</td>\n', color, a.len)];
      str = [str sprintf('<td bgcolor="#%s" align="center">%g</td>\n', color, a.nsecs)];
      str = [str sprintf('<td bgcolor="#%s" align="center">%g</td>\n', color, a.fs)];
      
      dt = sort(unique(diff(a.x)), 1, 'descend');
      dttag = '';
      if length(dt) > 10
        dt = dt(1:10);
        dttag = '...';
      end
      
      str = [str sprintf('<td bgcolor="#%s" align="center">%s%s</td>\n', color, regexprep(num2str(dt'), '\s*', ', '), dttag)];
      
      str = [str sprintf('<td bgcolor="#%s" align="center">%g</td>\n', color, max(a.y))];
      str = [str sprintf('<td bgcolor="#%s" align="center">%g</td>\n', color, min(a.y))];
      str = [str sprintf('<td bgcolor="#%s" align="center">%g</td>\n', color, mean(a.y))];
      
      str = [str sprintf('<td bgcolor="#%s" align="center">%s</td>\n', color, char(a.yunits))];
      
      
      str = [str sprintf('</tr>\n')];
    catch Me
      warning('Failed to process [%s], [%s]', a.name, Me.message);
    end
  end
  
  str = [str sprintf('</table>\n')];
  
end


function [tsAOs, fsAOs, xyAOs, xyzAOs, cAOs, tfAOs] = sortObjects(as)
  
  
  tsAOs  = [];
  fsAOs  = [];
  xyAOs  = [];
  xyzAOs = [];
  cAOs   = [];
  tfAOs  = [];
  
  consistent = 1;
  for jj = 1:numel(as)
    % Check if AOs are consistent (all containing data of the same class):
    if ~strcmpi(class(as(jj).data) , class(as(1).data) ), consistent = 0; end;
    switch class(as(jj).data)
      case 'tsdata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          tsAOs = [tsAOs as(jj)];
        end
      case 'fsdata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          fsAOs = [fsAOs as(jj)];
        end
      case 'xydata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          xyAOs = [xyAOs as(jj)];
        end
      case 'xyzdata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name); %#ok<*WNTAG>
        else
          xyzAOs = [xyzAOs as(jj)];
        end
      case 'cdata'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          cAOs = [cAOs as(jj)];
        end
      case 'tfmap'
        if isempty(as(jj).y)
          warning('AO %s has no data and will not be plotted', as(jj).name);
        else
          tfAOs = [tfAOs as(jj)];
        end
      otherwise
        warning('!!! Unknown data type %s', class(as(jj).data));
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

