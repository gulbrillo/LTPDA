% SCATTERDATA Creates from the y-values of two input AOs an new AO(xydata)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SCATTERDATA This method creates from the y-values of the
%              input AOs a new AO with xydata. The y-values of the first
%              input will be the x-values of the new AO and the y-values of
%              the second AO will be the y-values of the new AO.
%
% CALL:        b = scatterData(a1, a2, pl)
%
% INPUTS:      aN   - input analysis objects (two)
%              pl   - input parameter list
%
% OUTPUTS:     b    - output analysis object
%
% Possible actions:
% 
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'scatterData')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = scatterData(varargin)

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

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Check number of input AOs
  if numel(as) ~= 2
    error('### This method can only handle two input AOs');
  end

  % Check the length of both AOs
  if (len(as(1)) ~= len(as(2)))
    error('### The length of both input AOs must be the same');
  end
  
  a1 = as(1);
  a2 = as(2);
  
  xy = xydata();
  xy.setY(a2.y);
  xy.setDy(a2.dy);
  xy.setYunits(a2.yunits);
  yname = a2.name;
  if isempty(yname)
    yname = a2.yaxisname;
  end
  xy.setYaxisName(yname);
  xy.setX(a1.y);
  xy.setDx(a1.dy);
  xy.setXunits(a1.yunits);
  yname = a1.name;
  if isempty(yname)
    yname = a1.yaxisname;
  end
  xy.setXaxisName(yname);
  
  bs = ao(xy);
  bs.name = sprintf('scatterData(%s, %s)', ao_invars{1}, ao_invars{2});
  bs.description = [a1.description, ' ', a2.description];
  
  bs.addHistory(getInfo('None'), pl, ao_invars, [a1.hist a2.hist]);

  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
  pl = plist.EMPTY_PLIST;
end

