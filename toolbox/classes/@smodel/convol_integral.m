% CONVOL_INTEGRAL implements the convolution integral for smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CONVOL_INTEGRAL implements the convolution integral to evaluate
% the time-domain response of smodel objects whose impulse response is h(t),
% to input signals in_signal(t):
%   o(t) = int(h(t1) * in_signal(t-t1), t1=0..t)        (1)
%
% CALL:        out = convol_integral(mdl, sig)
%
% INPUTS:      mdl    smodel with the time-domain impulse response of
%                     the system
%              sig    smodel with the time-domain applied signal
%
% OUTPUTS:     out    smodel with the time-domain response of the system
%
% NOTE:        Eq (1) assumes that in_signal(t<0) = 0
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'convol_integral')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = convol_integral(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all input smodels and plists
  [mdls, smodel_invars, rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  pl        = utils.helper.collect_objects(rest(:), 'plist');
   
  % Merge with default plist
  usepl = applyDefaults(getDefaultPlist(), pl);
    
  % Check for the number of inputs
  if numel(mdls) ~= 2
    error('### Please provide an smodel with the system impulse response and an smodel with the signal')
  else 
    mdl = copy(mdls(1), false);
    sig = copy(mdls(2), false);
  end
  
  % Replace .* like expressions with * to allow symbolic evaluation
  h = utils.prog.convertComString(mdl.expr.s, 'ToSymbolic');
  in_signal = utils.prog.convertComString(sig.expr.s, 'ToSymbolic');

  % Go symbolic now
  syms t t1
  % Input Signal
  in_signal_t1 = sym(regexprep(in_signal,'\<t\>','t1'));
  
  % System impulse response
  h_t_t1 = sym(regexprep(h,'\<t\>','(t-t1)'));
  
  % Calculate the system response via convolution (linear system)
  out_s = simplify(int([h_t_t1 * in_signal_t1], t1, 0, t));
  
  % Go back to string after calcuation
  out.expr.s = utils.prog.mup2mat(out_s);
  
  % Replace * like expressions with .* to allow numeric evaluation
  out.expr.s = utils.prog.convertComString(out.expr.s , 'FromSymbolic');
  
  % Set variables, units
  out.setXvar(sig.xvar);
  out.setXunits(sig.xunits);
  out.setYunits(mdl.yunits * sig.yunits);
  
  % Add history step
  out.addHistory(getInfo('None'), usepl, [smodel_invars(:)], [mdls(:).hist]);
  
  % Set output
  
  % Single output
  varargout{1} = out;
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
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pls);
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

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end




