% SIMPLEX Multidimensional unconstrained nonlinear minimization (Nelder-Mead)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Multidimensional unconstrained nonlinear minimization 
%              (Nelder-Mead algorithm)
%
%              For more information, type 'doc fminsearch'
%
% CALL:        >> p = simplex(a,pl)
%
% INPUTS:      pl   - the output data
%              a    - input analysis object
%
% OUTPUTS:
%              p    - output pest object containing the estimated parameters.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'simplex')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = simplex(varargin)

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
  if nargout == 0
    error('### Simplex cannot be used as a modifier. Please give an output variable.');
  end
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  xo        = find_core(pl, 'x0');
  fun       = find_core(pl, 'function');
  param     = find_core(pl, 'FitParams');
  
  if isempty(xo)
    error('### Simplex needs a starting guess. Please input a ''x0''.');
  end
  
  if isempty(fun)
    error('### Simplex needs a function to minimize.');
  end

  xo = fminsearch(fun,xo, ...
                  optimset('Display',     find_core(pl,'display'), ...
                           'FunValCheck', find_core(pl,'FunValCheck'), ...
                           'MaxFunEvals', find_core(pl,'MaxFunEvals'), ...
                           'MaxIter',     find_core(pl,'MaxIter'), ...
                           'OutputFcn',   find_core(pl,'OutputFcn'), ...
                           'PlotFcns',    find_core(pl,'PlotFcns'), ...
                           'TolX',        find_core(pl,'TolX'), ...
                           'TolFun',      find_core(pl,'TolFun')  ...
                           ));

   
  if ~isempty(param)
    for i = 1:numel(xo)
      fprintf('###  Simplex estimate: %s = %d \n',param{i},xo(i))
    end
  end
  
  if find_core(pl, 'txt') 
    save('parameters_simplex.txt','xo','-ASCII')
  end   
  
  p = pest(xo);
  p.setName('Simplex Estimate');
  p.setNames(param{:});

  p.description = 'SIMPLEX Multidimensional unconstrained nonlinear minimization.';

  % add history
  p.addHistory(getInfo('None'), getDefaultPlist, ao_invars, [as(:).hist]);

  % Set output
  if nargout == numel(p)
    % List of outputs
    for ii = 1:numel(p)
      varargout{ii} = p(ii);
    end
  else
    % Single output
    varargout{1} = p;
  end
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
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl_default = buildplist()
  
  pl_default = plist();
  
  % function
  p = param({'function','Function handle to minimize.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % xo
  p = param({'x0','The starting point.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % Display
  p = param({'Display','Level of display..'}, {1, {'iter','off', 'notify', 'final'}, paramValue.SINGLE});
  pl_default.append(p);
  
  % FunValCheck
  p = param({'FunValCheck',['Check whether objective function values are valid. ' ...
                            '''on'' displays an error when the objective function ' ...
                            'returns a value that is complex, Inf or NaN. ''off'' ' ...
                            '(the default) displays no error.']}, {1, {'off','on'}, paramValue.SINGLE});
  pl_default.append(p);
  
  % MaxFunEvals
  p = param({'MaxFunEvals','Maximum number of function evaluations allowed.'}, paramValue.DOUBLE_VALUE(1e3));
  pl_default.append(p);
  
  % MaxIter
  p = param({'MaxIter','Maximum number of iterations allowed.'}, paramValue.DOUBLE_VALUE(1e3));
  pl_default.append(p);
  
  % OutputFcn
  p = param({'OutputFcn','User-defined function that is called at each iteration.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % PlotFcns
  p = param({'PlotFcns','Plots various measures of progress while the algorithm executes.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % TolFun
  p = param({'TolFun','Termination tolerance on the function value.'}, paramValue.DOUBLE_VALUE(1e-5));
  pl_default.append(p);
  
  % TolX
  p = param({'TolX','Termination tolerance on x.'}, paramValue.DOUBLE_VALUE(1e-5));
  pl_default.append(p);
  
  % FitParams
  p = param({'FitParams','The names of the parameters to fit.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % txt
  p = param({'txt','Set to true if a print of the parameters into a txt file is desired.'}, paramValue.FALSE_TRUE);
  pl_default.append(p);
  
  
  
end

