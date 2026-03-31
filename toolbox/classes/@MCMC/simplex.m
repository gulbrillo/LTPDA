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
% <a href="matlab:utils.helper.displayMethodInfo('MCMC', 'MCMC.simplex')">Parameters Description</a>
%
%
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

  % Collect all plists
  pl = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  if nargout == 0
    error('### Simplex cannot be used as a modifier. Please give an output variable.');
  end
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  xo        = find(pl, 'x0');
  param     = find(pl, 'FitParams');
  model     = find(pl, 'model');
  lp        = find(pl, 'log parameters');
  freqs     = find(pl, 'freqs');
  fin       = find(pl, 'input');
  fout      = find(pl, 'output');
  noise     = find(pl, 'noise');
  inNames   = find(pl, 'inNames');
  outNames  = find(pl, 'outNames');
  inLogL    = find(pl, 'func');
  applyN    = find(pl, 'apply negative');
  
  if ~isempty(fin) && ~isempty(noise) && ~isempty(fout)
    if (isa(fin, 'ao') && isa(fout, 'ao') && isa(noise, 'ao'))

      Nexp = numel(fin(1,:));
      
      spl(1:Nexp) = plist();

      % Store the data into structure arrays
      data = MCMC.ao2strucArrays(plist('in',fin,'out',fout,'S',noise,'Nexp',Nexp));

    else
      error('### Inputs ''in'', ''out'' and ''noise'' must be AO objects.')
    end
  else
    Nexp  = 1;
    freqs = {1};
    data  = 1;
  end
  
  % check number of parameters
  if numel(double(xo)) ~= numel(param)
    error('### Please check number of numerical values ''x0'' and number of parameter names ''FitParams''...')
  end
  
  % Define bode plist for ssm models
  for kk = 1:Nexp
    spl(kk) = plist('reorganize', false, 'f', freqs{kk},...
      'inputs',inNames,'outputs',outNames);
  end
  
  if isempty(xo)
    error('### Simplex needs a starting guess. Please input a ''x0''.');
  end
  
  logL = MCMC.defineLogLikelihood(xo, model, data, param, lp, inLogL, Nexp, freqs, pl);
  
  % create a new loglikehood with minus sign?
  logL = applyNegativeSign(logL, applyN);
  
  xo = fminsearch(logL, double(xo), ...
                  optimset('Display',     find(pl,'display'), ...
                           'FunValCheck', find(pl,'FunValCheck'), ...
                           'MaxFunEvals', find(pl,'MaxFunEvals'), ...
                           'MaxIter',     find(pl,'MaxIter'), ...
                           'OutputFcn',   find(pl,'OutputFcn'), ...
                           'PlotFcns',    find(pl,'PlotFcns'), ...
                           'TolX',        find(pl,'TolX'), ...
                           'TolFun',      find(pl,'TolFun')  ...
                           ));

   
  if ~isempty(param)
    for i = 1:numel(xo)
      fprintf('###  Simplex estimate: %s = %d \n',param{i},xo(i))
    end
  end
  
  if find(pl, 'txt') 
    save('parameters_simplex.txt','xo','-ASCII')
  end   
  
  p = pest(xo);
  p.setName('Simplex Estimate');
  if ~isempty(param)
    p.setNames(param{:});
  end
  
  p.description = 'SIMPLEX Multidimensional unconstrained nonlinear minimization.';

  % add history
  p = addHistory(p,getInfo('None'), pl, [], []);

  % Set output
  varargout{1} = p;
  
end

%--------------------------------------------------------------------------
% Apply negative sign to the log-likelihood function
%--------------------------------------------------------------------------
function inLogL = applyNegativeSign(inLogL, applyN)

  if applyN
    inLogL = @(p) -inLogL(p);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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
  
  % INPUT
  p = param({'INPUT','The injection signals.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % OUTPUT
  p = param({'OUTPUT','The measured output data.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % NOISE
  p = param({'NOISE','The noise data.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % MODEL
  p = param({'MODEL','The model to use.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % FREQS
  p = param({'FREQS','The frequencies to calculate the bode. For SSMs.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  %X0
  p = param({'X0','The starting point.'}, paramValue.EMPTY_DOUBLE);
  p.addAlternativeKey('paramValues');
  p.addAlternativeKey('p0');
  pl_default.append(p);
  
  % INAMES
  p = param({'INNAMES','The injection port names. For SSM models.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % OUTNAMES
  p = param({'OUTNAMES','The output ports names. For SSM models.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % DISPLAY
  p = param({'DISPLAY','Level of display..'}, {1, {'iter','off', 'notify', 'final'}, paramValue.SINGLE});
  pl_default.append(p);
  
  % FUNVALCHECK
  p = param({'FUNVALCHECK',['Check whether objective function values are valid. ' ...
                            '''on'' displays an error when the objective function ' ...
                            'returns a value that is complex, Inf or NaN. ''off'' ' ...
                            '(the default) displays no error.']}, {1, {'off','on'}, paramValue.SINGLE});
  pl_default.append(p);
  
  % MAXFUNEVALS
  p = param({'MAXFUNEVALS','Maximum number of function evaluations allowed.'}, paramValue.DOUBLE_VALUE(1e3));
  pl_default.append(p);
  
  % MAXITER
  p = param({'MAXITER','Maximum number of iterations allowed.'}, paramValue.DOUBLE_VALUE(1e3));
  pl_default.append(p);
  
  % OUTPUTFCN
  p = param({'OUTPUTFCN','User-defined function that is called at each iteration.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % PLOTFCNS
  p = param({'PLOTFCNS','Plots various measures of progress while the algorithm executes.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % TOLFUN
  p = param({'TOLFUN','Termination tolerance on the function value.'}, paramValue.DOUBLE_VALUE(1e-5));
  pl_default.append(p);
  
  % TOLX
  p = param({'TOLX','Termination tolerance on x.'}, paramValue.DOUBLE_VALUE(1e-5));
  pl_default.append(p);
  
  % FITPARAMS
  p = param({'FITPARAMS','The names of the parameters to fit.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % LOGPARAMS
  p = param({'LOG PARAMETERS','The parameters to sample in log-scale.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % TXT
  p = param({'TXT','Set to true if a print of the parameters into a txt file is desired.'}, paramValue.FALSE_TRUE);
  pl_default.append(p);
  
  % FUNC
  p = param({'FUNC','The function handle to minimize.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % APPLY NEGATIVE
  p = param({'APPLY NEGATIVE',['For the case of a log-likelihood function, a negative sign is added ',...
              'to the numerical value, because the SIMPLEX is a minimisation algorithm']}, paramValue.TRUE_FALSE);
  pl_default.append(p);
  
end

