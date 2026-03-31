% BANDREJECT AOs containing time-series data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: BANDREJECT AOs containing time-series data. All other AOs with
%              no time-series data are skipped but appear in the output.
%              
% CALL:        b = bandreject(a, pl)      - use plist to get parameters
%              b = bandreject(a1, a2, pl) - bandreject both a1 and a2;
%                                           b is then a 2x1 vector.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'bandreject')">Parameters Description</a>
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = bandreject(varargin)

  callerIsMethod = utils.helper.callerIsMethod;
  
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

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % Get parameters from plist
  fc     = find_core(pl, 'fc');
  order  = find_core(pl, 'order');
  method = find_core(pl, 'method');

  % Loop over input AOs
  for jj = 1:numel(bs)
    if isa(bs(jj).data, 'tsdata')
      
      % make filter
      inhist = bs(jj).hist;
      ff = miir.bandreject(bs(jj).fs, fc, order);
      
      % apply filter with chosen method
      bs(jj) = feval(method, bs(jj), ff);
            
      if ~callerIsMethod
        % set name
        bs(jj).name = sprintf('bandreject(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhist);
      end
      
      % set procinfo
      bs(jj).procinfo = plist('filter', ff);
      
      % Clear the errors since they don't make sense anymore
      clearErrors(bs(jj));
    else
      warning('!!! BANDREJECT only works on tsdata objects. Skipping AO %s', ao_invars{jj});
    end
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
  
  % Factor
  p = param({'FC', 'The lower and upper corner frequencies for the filter (2x1 vector).'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % Order
  p = param({'ORDER', 'The order of the filter to use.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  % Method
  p = param({'method', 'The filter method to use.'}, {1, {'filter', 'filtfilt'}, paramValue.SINGLE});
  pl.append(p);
  
end


