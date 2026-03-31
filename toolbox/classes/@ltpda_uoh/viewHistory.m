% VIEWHISTORY Displays the history of an object as a dot-view or a MATLAB figure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: VIEWHISTORY Displays the history of an object depending of
%              the parameter values as a dot-view or a MATLAB history
%              figure.
%
% CALL:        viewHistory(obj);
%              viewHistory(obj, pl);
%
% INPUTS:      obj: Single object with history
%              pl:  parameter list with different parameters.
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'viewHistory')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = viewHistory(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect all AOs
  obj = utils.helper.collect_objects(varargin(:), '');
  pl  = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Check that the input object is only a single object
  if numel(obj) ~= 1
    error('### This methods works only with one single object');
  end
  
  % Check that the input object effectively contains history information
  if isempty(obj.hist)
    warning('### The object has no history!');
  else
    % be sure that pl is a single plist.
    pl = combine(pl, plist());
    
    app = pl.find_core('application');
    if isempty(app)
      app = 'default';
    end
    
    % Combine input plist with dedfault plist
    pl = applyDefaults(getDefaultPlist(app), pl);
    
    switch lower(pl.find_core('application'))
      case 'dot view'
        try
          
          % check where we are
          stackStr = '';
          stack = dbstack();
          if numel(stack) > 1
            stackStr = sprintf('Generated from: %s', stack(end).file);
          else
            stackStr = 'Generated from terminal';
          end
          
          titleString = sprintf('History Graph for [%s/%s]', obj.name, obj.UUID);
          if ~isempty(obj.description)
            titleString = [titleString sprintf('\n%s', obj.description)];
          end
          if ~isempty(stackStr)
            titleString = [titleString sprintf('\n%s', stackStr)];
          end
          titleString = [titleString sprintf('\nCreated %s\n\n', time().format)];
          
          dotview(obj.hist, pl.pset('title', titleString));
        catch Me
          warning('### Generating a history tree with graphviz/dot failed: [%s]', Me.message);
          disp(' ');
          warning('off', 'backtrace');
          cl = onCleanup(@()warning('on', 'backtrace'));
          warning('<strong>How To Install:</strong> <a href="matlab:web(''additional_progs.html'')">graphviz/dot</a>');
          viewHistory(obj, plist('application', 'command view'));
        end
        
      case 'command view'
        type(obj);
        
      otherwise
        error('### Unknown application to show the history [%s]', pl.find_core('application'));
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pls = getDefaultPlist(sets{1});
  else
    sets = {...
      'Default', ...
      'DOT View', ...
      'command view'};
    
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  pl = plist();
  
  p = param({'application', 'Application which should display the history'}, {1, {'DOT View', 'command view'}, paramValue.SINGLE});
  pl.append(p);
  
  switch lower(set)
    case 'default'
      pl = getDefaultPlist('dot view');
      
    case 'dot view'
      pl.setDefaultForParam_core('application', 'dot view');
      
      p = param({'filename', ''}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      p = param({'view', ''}, paramValue.TRUE_FALSE);
      pl.append(p);
      
      prefs = getappdata(0, 'LTPDApreferences');
      ext = char(prefs.getExternalPrefs.getDotOutputFormat);
      p = param({'format', ''}, paramValue.STRING_VALUE(ext));
      pl.append(p);
      
    case 'command view'
      pl.setDefaultForParam_core('application', 'command view');
      
      pl.append(ltpda_uoh.getInfo('type').plists);
      
    otherwise
      error('### Unknown parameter set [%s].', set);
  end
end

