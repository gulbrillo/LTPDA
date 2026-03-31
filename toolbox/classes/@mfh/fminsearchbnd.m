% FMINSEARCHBND uses a simplex search to minimise the given function handle
% subject to constraints on the function arguments.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FMINSEARCHBND uses a simplex search to minimise the given
%              function handle subject to constraints
%
% The function handle is minimised a function of its 'inputs' subject to constraints
%
% CALL:        min = fminsearchbnd(fh, pl)
%
% INPUTS:      fh   - input function handle object (@mfh)
%              pl   - input parameter list
%
% OUTPUTS:    min   - output pest object containing fit details
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'fminsearchbnd')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = fminsearchbnd(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all function handles
  [f, f_invars] = utils.helper.collect_objects(varargin(:), 'mfh', in_names);
  
  % input plist?
  ipl = [];
  if nargin > 1
    if ~isa(varargin{2}, 'plist')
      error('The second input to fminsearchbnd should be a plist');
    end
    ipl = varargin{2};
  end
  
  % some basic checks
  if numel(f.inputs) > 1
    error('mfh/fminsearchbnd can only minimise a function of one variable');
  end
  
  % apply defaults
  pl = applyDefaults(getDefaultPlist(), ipl);
  
  % create function handle
  fh_str = f.function_handle();
  
  % declare objects locally
  declare_objects(f);
  
  % create function handle
  fh = eval(fh_str);
  
  % get inputs
  p0 = pl.find_core('p0');
  if isempty(p0)
    error('Please specify an initial guess for the parameter vector');
  end
  
  % get upper bounds
  UB = pl.find_core('UB');
  if isempty(UB)
    UB = Inf*ones(size(p0));
  end
  
  if numel(UB) ~= numel(p0)
    error('Number of upper bounds must match number of parameters');
  end
  
  % get lower bounds
  LB = pl.find_core('LB');
  if isempty(LB)
    LB = -Inf*ones(size(p0));
  end
  
  if numel(LB) ~= numel(p0)
    error('Number of upper bounds must match number of parameters');
  end
  
  
  % get/create names for the output parameters
  paramNames = pl.find_core('param names');
  if isempty(paramNames)
    pname = f.inputs{1};
    for ll=1:numel(double(p0))
      paramNames = [paramNames {sprintf('%s(%d)', pname, ll)}];
    end
  end
  
  % minimise
  opts = pl.find_core('options');
  if isempty(opts)
    
    % call fminsearchbnd wrapper
    [X, Xhist, Fhist] = dosearchbnd(fh, double(p0), double(LB),double(UB), pl,paramNames,f.name(),f.func());
    
  else
    % call bounded fminsearch code directly with specified options
    X = utils.math.fminsearchbnd_core(fh, double(p0), double(LB), double(UB),opts);
  end
  
  % create output object
  out = pest();
  out.setY(X);
  out.setNames(paramNames);
  out.setName(sprintf('fminsearchbnd(%s)', f.name));
  
  if ~callerIsMethod
    
    % add history
    out.addHistory(getInfo('None'), pl, f_invars, f.hist);
    
    % build procinfo
    pinfo = plist();
    
    if exist('Xhist','var');
      % add number of iterations
      p = param('Ninit', length(Xhist));
      pinfo.append(p);
      
      % add parameter history
      p = param('Parameter Chain',Xhist);
      pinfo.append(p);
    end
    
    if exist('Fhist','var')
      % add feval history
      p = param('FEVAL Chain', Fhist);
      pinfo.append(p);
    end
    
    % set procinfo
    out.setProcinfo(pinfo);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
  
end

%--------------------------------------------------------------------------
% Fminsearchbnd wrapper
%--------------------------------------------------------------------------
function [X, Xhist, fHist] = dosearchbnd(fh,p0,lb,ub,pl,paramNames,funcName,funcStr)
  
  % initialize histories
  Xhist = [];
  fHist = [];
  
  % Get output file
  outFile = pl.find_core('Output File');
  if isempty(outFile)
    outID = -1;
  else
    % parse output file
    [outPath, outName] = fileparts(outFile);
    % create if necessary
    if ~exist(outPath,'dir'), mkdir(outPath); end
    % open file
    outID = fopen(outName,'w+');
    % print header
    fprintf(outID,[...
      '%% Log file for mfh/fminsearchbnd, executed %s\n',...
      '%% mfh Name: %s\n',...
      '%% mfh Function: %s\n'],...
      datestr(now,'yyyy-mm-dd HH:MM:SS'),funcName,funcStr);
    fprintf(outID,'%% Iteration\t Value');
    for ii = 1:length(paramNames)
      fprintf(outID,'\t\t\t%s',paramNames{ii});
    end
    fprintf(outID,'\n');
  end
  
  % open figure
  if pl.find_core('Show Plot')
    figh = figure();
    m = ceil(sqrt(numel(p0)));
    axh(1) = subplot(m,m,1);
    for ii = 1:numel(p0)
      axh(ii+1) = subplot(m,m,1+ii);
    end
  else
    figh = -1;
  end
  
  % build options
  opts = optimset(...
    'Display', pl.find_core('display'), ...
    'MaxIter', pl.find_core('maxiter'), ...
    'TolX', pl.find_core('tolx'),...
    'OutputFcn',@outFcn);
  
  X = utils.math.fminsearchbnd_core(fh, p0,lb,ub,opts);
  %X = fminsearch(fh,p0,opts);
  
  % close output file if open
  if outID > 0
    fclose(outID);
  end
  
  % define output function
  function stop = outFcn(x,optimvalues,state)
    stop = false;
    if strcmpi(state,'iter')
      
      % write history
      Xhist = [Xhist; x];
      fHist = [fHist; optimvalues.fval];
      
      % write state to file
      if outID > 0
        fprintf(outID,'%i\t\t%e',optimvalues.iteration, optimvalues.fval);
        for jj = 1:length(x)
          fprintf(outID, '\t\t%e',x(jj));
        end
        fprintf(outID, '\n');
      end
      
      % do plots
      if figh > 0
        figure(figh)
        % funciton eval plots
        plot(axh(1),0:optimvalues.iteration,fHist,'bo-');
        title(axh(1),sprintf('Function Value, Currently %3.2e', optimvalues.fval));
        ylabel(axh(1),'Value');
        xlabel(axh(1),'Iteration');
        grid(axh(1),'on');
        % parameter plots
        for jj = 1:length(x)
          plot(axh(jj+1),0:optimvalues.iteration,Xhist(:,jj),'bo-');
          title(axh(jj+1),sprintf('%s, Currently %3.2e', paramNames{jj}, x(jj)));
          ylabel(axh(jj+1),'Value');
          xlabel(axh(jj+1),'Iteration');
          grid(axh(jj+1),'on');
        end
        drawnow
      end
      
    end
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
    pl   = getDefaultPlist();
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
  
  % empty plist
  pl = plist();
  
  % param names
  p = param({'param names', 'A optional cell-array of parameter names to set in the final pest object. If empty, the input names from the function handle will be taken.'}, {});
  pl.append(p);
  
  % p0
  p = param({'p0', 'Array of initial parameter values. If empty, an array of ones of the appropriate length will be used.'}, []);
  pl.append(p);
  
  % UB
  p = param({'UB', 'Array of upper bounds for parameters. If empty, the upper bound is +Inf for all variables.'}, []);
  pl.append(p);
  
  % LB
  p = param({'LB', 'Array of lower bounds for parameters. If empty, the lower bound is -Inf for all variables.'}, []);
  pl.append(p);
  
  % TolX
  p = param({'TolX', 'Termination tolerance on x, the current point. (See >> help fminsearch)'}, []);
  pl.append(p);
  
  % Display
  p = param({'Display', 'Display setting for fminsearch. (See >> help fminsearch)'}, 'iter');
  pl.append(p);
  
  % MaxIter
  p = param({'MaxIter', 'Maximum number of iterations allowed. (See >> help fminsearch)'}, []);
  pl.append(p);
  
  % options
  p = param({'options', 'A complete options structure (as defined by optimset) to pass to fminsearch. (See >> help fminsearch)'}, []);
  pl.append(p);
  
  % Output file
  p = param({'Output File', 'Filename for (optional) logging of search steps. No logging if empty.'}, []);
  pl.append(p);
  
  % Output Plots
  p = param({'Show Plot','Displays search progress in a figure window'}, paramValue.FALSE_TRUE());
  pl.append(p);
  
end
