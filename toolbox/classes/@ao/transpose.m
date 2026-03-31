% TRANSPOSE overloads the .' operator for Analysis Objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TRANSPOSE overloads the .' operator for Analysis Objects.
%
% CALL:        a = a1.'
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'transpose')">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = transpose(varargin)
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  if pl.find_core('complex')
    fcn = 'ctranspose';
  else
    fcn = 'transpose';
  end
  
  for kk = 1:numel(bs)
    
    if isa(bs(kk).data, 'xyzdata')
      warning('Code me up.');
    else
      % Special case for cdata-objects because this objects doesn't have x values
      y = bs(kk).data.y;
      dy = bs(kk).data.dy;
      bs(kk).data.setY([]);
      bs(kk).data.setDy([]);
      bs(kk).data.setY(feval(fcn, y));
      bs(kk).data.setDy(feval(fcn, dy));
      
      if isa(bs(kk).data, 'data2D')
        
        x  = bs(kk).data.x;
        dx = bs(kk).data.dx;
        
        % cache the toffset if this is a tsdata object
        if isa(bs(kk).data, 'tsdata')
          toffset = bs(kk).data.toffset;
        end
        
        % Set the y-value to an empty array because the y-data keeps always the same
        % shape
        bs(kk).data.setX([]);
        bs(kk).data.setDx([]);
        
        bs(kk).data.setX(feval(fcn, x));
        bs(kk).data.setDx(feval(fcn, dx));
        
        % and set the output toffset if we have tsdata
        if isa(bs(kk).data, 'tsdata')
          bs(kk).data.setToffset(toffset);
        end      
      end
    end
    
    % Set new AO name
    bs(kk).name = ['transpose(' ao_invars{kk} ')'];
    % Add history
    bs(kk).addHistory(getInfo('None'), pl, ao_invars(kk), bs(kk).hist);
  end
  
  % clear errors
  bs.clearErrors(pl);
  
  % Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
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

function pl = buildplist()
  pl = plist();
  
  % complex
  p = param({'complex', 'Use complex conjugate transpose'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end

% END
