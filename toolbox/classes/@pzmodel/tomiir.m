% TOMIIR converts a pzmodel to an IIR filter using a bilinear transform.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TOMIIR converts a pzmodel to an IIR filter using a bilinear
%              transform.
%
% CALL:        f = tomiir(pzm, fs); % construct for this sample frequency fs
%              f = tomiir(pzm, pl); % construct from plist
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'tomiir')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = tomiir(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check output arguments number
  if nargout == 0
    error('### pzmodel/tomiir cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [pzms, pzm_invars] = utils.helper.collect_objects(varargin(:), 'pzmodel', in_names);
  pls  = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Store inhists to suppress intermediate history steps
  inhists = [pzms(:).hist];
  
  % Get default parameters
  pl = applyDefaults(getDefaultPlist, pls);
  
  % Decide on a deep copy or a modify
  pzms = copy(pzms, nargout);
  
  % Get fs
  fs = pl.find_core('fs');
  if nargin == 2
    if isnumeric(varargin{2})
      fs = varargin{2};
    end
  end
  
  si = size(pzms);
  f(si(1), si(2)) = miir();
  for kk = 1:numel(pzms)
    
    % get a and b coefficients
    [a,b] = pzm2ab(pzms(kk), fs);
    
    % throws a warning if the model has a delay
    if(pzms(kk).delay~=0)
      disp('!!!  PZmodel delay is not used in the discretization')
    end
    % make MIIR filter
    f(kk) = miir(a,b,fs);
    
    if ~callerIsMethod
      % create new history for the case that the method isn't called from
      % a LTPDA method
      f(kk).addHistory(getInfo, pl, pzm_invars(kk), inhists(kk));
    end
  end
  
  % Set output
  if nargout == numel(f)
    % List of outputs
    for ii = 1:numel(f)
      varargout{ii} = f(ii);
    end
  else
    % Single output
    varargout{1} = f;
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
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
  ii.setModifier(false);
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

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function plo = buildplist()
  plo = plist();
  
  % FS
  p = param({'fs', 'Frequency of the iir filter.'}, paramValue.DOUBLE_VALUE(1));
  plo.append(p);
  
end

