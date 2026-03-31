% SETPLOTFIGURE sets the 'figure' property of a the object's plotinfo.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETPLOTFIGURE sets the 'figure' property of a the
%              object's plotinfo.
%
% If the object currently has no plotinfo object defined, a default one is
% created.
%
%
% CALL:            objs.setPlotFigure(fh);
%            out = objs.setPlotFigure(fh);
%
% INPUTS:
%                  objs - Any shape of ltpda_uoh objects
%                    fh - A valid figure handle.
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'setPlotFigure')">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setPlotFigure(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Process inputs
  [objs, ~, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_uoh', in_names);
  [pl,   ~, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  if numel(pl) == 0 && numel(rest) == 0
    error('Specify a valid figure handle.');
  end
  
  % Apply defaults.
  pl = applyDefaults(getDefaultPlist, pl);
  
  if ~isempty(rest) && ~isempty(rest{1}) && ishghandle(rest{1})
    val = rest{1};
    pl.pset('handle', val);
  else
    val = pl.find_core('handle');
  end
  
  % decide on a deep copy
  bs = copy(objs, nargout);
  
  for kk=1:numel(bs)
    
    obj = bs(kk);
    
    % Special case if the value for the figure is empty AND the plotinfo is emtpy.
    if isempty(val) && isempty(obj.plotinfo)
      % Don't create a plotinfo-object in this case.
      continue;
    end
    
    if isempty(obj.plotinfo)
      obj.plotinfo = plotinfo();
    end
    
    obj.plotinfo.figure = val;
    
  end
  
  % set outputs
  varargout = utils.helper.setoutputs(nargout, bs);
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  pl = plist({'handle', 'A valid figure handle.'}, paramValue.EMPTY_DOUBLE);
end
