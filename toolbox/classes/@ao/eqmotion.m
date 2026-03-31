% EQMOTION solves numerically a given linear equation of motion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: EQMOTION solves numerically a given linear equation
% of motion:
%                d^2 x             dx
% F(t) = alpha2 ------- + alpha1 ------ + alpha0 (x-x0)
%                dt^2              dt
% 
% CALL:              eqmotion(a)
%                b = eqmotion(a,pl)
%
% INPUTS:      a  - analysis object(s) containing data as a function of
%                   time. 
%              pl - parameter list containing input parameters.
%
% OUTPUTS:     b  - analysis object(s) containing output data as a function
%                   of time.
% 
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'eqmotion')">Parameters Description</a>
% 
% NOTE: Derivative estimation is performed with the parabolic fit
% approximation by default [1, 2]. Try to change D#COEFF to use another
% method. D0COEFF is used to calculate a five point data smoother to be
% applied to the third term at the second member of the equation above. If
% you do not whant to smooth data (before the multiplication with alpha0)
% you have to input NaN for D0COEFF.
% See also help for ao/diff and utils.math.fpsder. 
% 
% REFERENCES:
% [1] L. Ferraioli, M. Hueller and S. Vitale, Discrete derivative
%     estimation in LISA Pathfinder data reduction, Class. Quantum Grav.,
%     7th LISA Symposium special issue.
% [2] L. Ferraioli, M. Hueller and S. Vitale, Discrete derivative
%     estimation in LISA Pathfinder data reduction
%     <a href="matlab:web('http://arxiv.org/abs/0903.0324v1','-browser')">http://arxiv.org/abs/0903.0324v1</a>
%
% SEE ALSO:    ao/diff, utils.math.fpsder
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = eqmotion(varargin)

  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Get Parameters
  alpha0    = find_core(pl,'ALPHA0');
  alpha1    = find_core(pl,'ALPHA1');
  alpha2    = find_core(pl,'ALPHA2');
  X0        = find_core(pl,'X0');
  d0c       = find_core(pl,'D0COEFF');
  d1c       = find_core(pl,'D1COEFF');
  d2c       = find_core(pl,'D2COEFF');
  tunits    = find_core(pl,'TARGETUNITS');
  
  % check if the params are AOs
  if ~isa(tunits,'unit')
    tunits = unit(tunits);
  end
  if ~isa(alpha0,'ao')
    alpha0 = cdata(alpha0);
    alpha0.setYunits(tunits./unit(as.yunits));
    alpha0 = ao(alpha0);
    alpha0.simplifyYunits;
  end
  if ~isa(alpha1,'ao')
    alpha1 = cdata(alpha1);
    alpha1.setYunits(tunits .* unit.seconds ./ unit(as.yunits));
    alpha1 = ao(alpha1);
    alpha1.simplifyYunits;
  end
  if ~isa(alpha2,'ao')
    alpha2 = cdata(alpha2);
    alpha2.setYunits(tunits .* (unit.seconds.^2) ./ unit(as.yunits));
    alpha2 = ao(alpha2);
    alpha2.simplifyYunits;
  end
  if ~isa(X0,'ao')
    if isempty(X0)
      X0 = cdata(0);
      X0.setYunits(as.yunits);
      X0 = ao(X0);
    else
      X0 = cdata(X0);
      X0.setYunits(as.yunits);
      X0 = ao(X0);
    end
  end
  if isa(d0c,'ao')
    d0c = d0c.data.y;
  end
  if isa(d1c,'ao')
    d1c = d1c.data.y;
  end
  if isa(d2c,'ao')
    d2c = d2c.data.y;
  end

  % go through analysis objects
  for kk = 1:numel(bs)
    
    %%% Calculate derivatives
    if ~isnan(d0c) % do the smoothing
      a0 = diff(bs(kk),plist('method', 'FPS', 'ORDER', 'ZERO', 'COEFF', d0c));
    else
      a0 = copy(bs(kk),1); % just use input data as they are
    end
    a1 = diff(bs(kk),plist('method', 'FPS', 'ORDER', 'FIRST', 'COEFF', d1c));
    a2 = diff(bs(kk),plist('method', 'FPS', 'ORDER', 'SECOND', 'COEFF', d2c));
    
    %%% Calculate Force
    b0 = (a0 - X0);
    b0 = b0*alpha0;
    b1 = a1*alpha1;
    b2 = a2*alpha2;
    bs(kk) = b2 + b1 + b0;
    % simplify units
    bs(kk).simplifyYunits(plist('prefixes', false));

    %%% Set Name
    bs(kk).name = sprintf('eqmotion(%s)', ao_invars{kk});

    if ~callerIsMethod
      %%% Set Name
      bs(kk).name = sprintf('eqmotion(%s)', ao_invars{kk});
      %%% Add History
      bs(kk).addHistory(getInfo('None'), pl, ao_invars(kk), [as.hist(kk)]);
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
  
  % ALPHA0
  p = param({'ALPHA0','Zero order coefficient. Input a cdata ao with the proper units or a number.'}, ...
    {1, {0}, paramValue.OPTIONAL});
  pl.append(p);
  
  % ALPHA1
  p = param({'ALPHA1','First order coefficient. Input a cdata ao with the proper units or a number.'},...
    {1, {0}, paramValue.OPTIONAL});
  pl.append(p);
  
  % ALPHA2
  p = param({'ALPHA2','Second order coefficient. Input a cdata ao with the proper units or a number.'}, ...
    {1, {0}, paramValue.OPTIONAL});
  pl.append(p);
  
  % X0
  p = param({'X0','Data offset. Input a cdata ao with the proper units or a number.'}, ...
    {1, {0}, paramValue.OPTIONAL});
  pl.append(p);
  
  % D0COEFF
  p = param({'D0COEFF','Data smoother coefficient.'}, ...
    {1, {-3/35}, paramValue.OPTIONAL});
  pl.append(p);
  
  % D1COEFF
  p = param({'D1COEFF','First derivative coefficient.'}, ...
    {1, {-1/5}, paramValue.OPTIONAL});
  pl.append(p);
  
  % D2COEFF
  p = param({'D2COEFF','Second derivative coefficient.'}, ...
    {1, {2/7}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Target units
  p = param({'TARGETUNITS','Set this parameter if you input just numbers for the ALPHA# coefficients.'}, ...
    {1, {'N'}, paramValue.OPTIONAL});
  pl.append(p);
  
end


