% LINFIT is a linear fitting tool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LINFIT is a linear fitting tool based on MATLAB's
% lscov function. It solves an equation in the form
%
%     Y = P(1) + X * P(2)
%
% for the fit parameters P.
% The output is a pest object where the fields are containing:
% Quantity                              % Field
% Fit parameters                            y
% Uncertainties on the fit parameters
% (given as standard deviations)            dy
% The reduced CHI2 of the fit              chi2
% The covariance matrix                    cov
% The degrees of freedom of the fit        dof
%
% CALL:       P = linfit(X, Y, PL)
%             P = linfit(A, PL)
%
% INPUTS:     Y   - dependent variable
%             X   - input variable
%             A   - data ao whose x and y fields are used in the fit
%             PL  - parameter list
%
% OUTPUT:     P   - a pest object with the fitting coefficients
%
%
% PARAMETERS:
%    'dy' - uncertainty on the dependent variable
%    'dx' - uncertainties on the input variable
%    'p0' - initial guess on the fit parameters used ONLY to propagate
%           uncertainities in the input variable X to the dependent variable Y
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'linfit')">Parameters Description</a>
%
% EXAMPLES:
%
%  %% Make fake AO from polyval
%   nsecs = 100;
%   fs    = 10;
%
%   u1 = unit('fm s^-2');
%   u2 = unit('nT');
%
%   pl1 = plist('nsecs', nsecs, 'fs', fs, ...
%     'tsfcn', 'polyval([10 1], t) + randn(size(t))', ...
%     'xunits', 's', 'yunits', u1);
%
%   pl2 = plist('nsecs', nsecs, 'fs', fs, ...
%     'tsfcn', 'polyval([-5 0.2], t) + randn(size(t))', ...
%     'xunits', 's', 'yunits', u2);
%
%   a1 = ao(pl1);
%   a2 = ao(pl2);
%
%  %% 1) Determine dependance from time of a time-series
%  %% Fit a stright line the a1 dependance from time
%   p1 = linfit(a1, plist());
%   p2 = linfit(a1, plist('dx', 0.1*ones(size(a1.x)), 'dy', 0.1*ones(size(a1.y)), 'P0', ao([0 0])));
%   p3 = linfit(a1, plist('dx', ao(0.1, plist('yunits', a1.xunits)), 'dy', ao(0.1, plist('yunits', a1.yunits)), 'P0', p1));
%
%  %% Compute fit: evaluating pest
%
%   b1 = p1.eval(plist('type', 'tsdata', 'XData', a1, 'xfield', 'x'));
%   b2 = p2.eval(plist('type', 'tsdata', 'XData', a1.x));
%   b3 = p3.eval(plist('type', 'tsdata', 'XData', a1.x));
%
%  %% Plot fit
%   iplot(a1, b1, b2, b3, plist('LineStyles', {'', '--', ':', '-.'}));
%
%  %% Remove linear trend
%   c = a1 - b1;
%   iplot(c)
%
%  %% 2) Determine dependance of a time-series from another time-series
%  %% Fit with a straight line the a1 dependance from a2
%
%   p1 = linfit(a1, a2, plist());
%   p2 = linfit(a1, a2, plist('dx', 0.1*ones(size(a1.x)), 'dy', 0.1*ones(size(a1.x)), 'P0', ao([0 0])));
%   p3 = linfit(a1, a2, plist('dx', ao(0.1, plist('yunits', a1.yunits)), 'dy', ao(0.1, plist('yunits', a2.yunits)), 'P0', p1));
%
%  %% Compute fit: evaluating pest
%
%   b1 = p1.eval(plist('type', 'xydata', 'XData', a1.y, 'xunits', a1.yunits));
%   b2 = p2.eval(plist('type', 'xydata', 'XData', a1));
%   b3 = p3.eval(plist('type', 'xydata', 'XData', a1.y, 'xunits', a1.yunits));
%
%  %% Build reference object
%   a12 = ao(plist('xvals', a1.y, 'yvals', a2.y, ...
%     'xunits', a1.yunits, 'yunits', a2.yunits));
%
%  %% Plot fit
%   iplot(a12, b1, b2, b3, plist('LineStyles', {'', '--', ':', '-.'}));
%
%   %% Remove linear trend
%   c = a12 - b3;
%   iplot(c)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = linfit(varargin)
  
  % check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % tell the system we are running
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % collect all AOs and plists
  [aos, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pli              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if nargout == 0
    error('### linfit can not be used as a modifier method. Please give at least one output');
  end
  
  % combine plists, making sure the user input is not empty
  pl = applyDefaults(getDefaultPlist(), pli);
  
  % extract arguments
  if (length(aos) == 1)
    % we are using x and y fields of the single ao we have
    argsname = ao_invars{1};
  elseif (length(aos) == 2)
    % we are using y fields of the two aos we have
    argsname = [ao_invars{1} ',' ao_invars{2}];
  else
    error('### linfit needs one or two input AOs');
  end
  
  % call polynomfit with fixed coefficients
  out = polynomfit(aos, pl.pset('orders', [0 1]));
  
  out.name = sprintf('linfit(%s)', argsname);
  out.addHistory(getInfo('None'), pl,  ao_invars, [aos(:).hist]);
  
  % set outputs
  varargout{1} = out;
  
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
    pl   = getDefaultPlist();
  end
  % build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(1);
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
  
  % default plist for linear fitting
  pl = plist.LINEAR_FIT_PLIST;
  
end

