% INTEGRATE integrates the data in AO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: INTEGRATE integrates the data in AO. The result is a single
%              valued AO.
%
% CALL:        bs = integrate(a1,a2,a3,...,pl)
%              bs = integrate(as,pl)
%              bs = as.integrate(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input,
%                     containing the integrate data
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'integrate')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = integrate(varargin)
  
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
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  

  % Extract method
  method = find_core(pl, 'method');
  
  for jj = 1:numel(bs)
    
    % Diff can't work for cdata objects since we need x data
    if isa(bs(jj).data, 'cdata')
    end
    
    % Compute integral with selected method
    yu = bs(jj).data.yunits;
    xu = bs(jj).data.xunits;
    switch lower(method)
      case 'trapezoidal'
        if isa(bs(jj).data, 'cdata')
          y      = bs(jj).data.getY;
          bs(jj).data = cdata(trapz(y));
        else
          x      = bs(jj).data.getX;
          y      = bs(jj).data.getY;
          bs(jj).data = cdata(trapz(x,y));
        end
        bs(jj).setYunits(yu * xu);
      case 'cumtrapz'
        if isa(bs(jj).data, 'cdata')
          y      = bs(jj).data.getY;
          bs(jj).data = cdata(trapz(y));
        else
          x      = bs(jj).data.getX;
          y      = bs(jj).data.getY;
          bs(jj).data.setY(cumtrapz(x,y));
        end
        bs(jj).setYunits(yu * xu);
      otherwise
        error('### Unknown method for computing the derivative.');
    end
    

    % name for this object
    bs(jj).name = sprintf('integrate(%s)', ao_invars{jj});
    % add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
  end
  
  % clear errors
  bs.clearErrors;
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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
  pl = plist();
  
  % Method
  p = param({'method',['The method to use. Choose between:<ul>', ...
    '<li>''Trapezoidal'' - integration using MATLAB''s trapz function</li>', ..., ...
    '<li>''cumtrapz'' - integration using MATLAB''s cumtrapz function</li>', ...
    '</ul>' ...
    ]},  {1, {'Trapezoidal','cumtrapz'}, paramValue.SINGLE});
  pl.append(p);
  
end

