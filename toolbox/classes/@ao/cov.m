% COV estimate covariance of data streams.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COV estimate covariance of data streams.
%
% CALL:        c = cov(a, b, pl)
%
% INPUTS:      pl   - a parameter list
%              a,b  - input analysis object
%
% OUTPUTS:     c    - output analysis object containing the covariance matrix.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'cov')">Parameters Description</a> 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cov(varargin)

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
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  if nargout == 0
    error('### cov cannot be used as a modifier. Please give an output variable.');
  end

  if numel(as) < 2
    error('### cov requires at least two input AOs to work.');
  end

  % Convolute the data
  smat = [];
  name = '';
  desc = '';
  for jj = 1:numel(as)
    smat = [smat as(jj).data.getY];
    units(jj) = as(jj).data.yunits;
    name = strcat(name, [',' ao_invars{jj}]);
    desc = strcat(desc, [' ' as(jj).description]);
  end  
  desc = strtrim(desc);
  plotInfo = [as(:).plotinfo];
  if ~isempty(plotInfo)
    plotInfo = plotInfo(end);
  end
  
  bs = ao(cdata(cov(smat)));
  bs.name = sprintf('cov(%s)', name(2:end));
  bs.description = desc;
  bs.plotinfo = plotInfo;
  % Unit handling is an issue: we provide a cdata output that only has one
  % unit ... so we can only set them if they are identical. 
  % Let's reset them in this case.
  if all(isequal(units, repmat(units(1), size(units))))
    bs.data.setYunits(units(1).^2);
  else
    warning('The objects have different units, so I cannot set an unique one to the outputs');
    bs.data.setYunits(unit());
  end
  if ~utils.helper.callerIsMethod
    bs.addHistory(getInfo('None'), getDefaultPlist, ao_invars, [as(:).hist]);
  end

  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
  ii.setModifier(false);
  ii.setArgsmin(2);
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

function pl_default = buildplist()
  pl_default = plist.EMPTY_PLIST;
end

