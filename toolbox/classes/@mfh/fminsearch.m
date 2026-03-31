% FMINSEARCH uses a simplex search to minimise the given function handle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FMINSEARCH uses a simplex search to minimise the given
%              function handle.
%
% The function handle is minimised a function of its 'inputs' by calling
% MATLAB's fminsearch() function.
%
% CALL:        min = fminsearch(fh, pl)
%
% INPUTS:      fh   - input function handle object (@mfh)
%              pl   - input parameter list
%
% OUTPUTS:    min   - output pest object containing fit details
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'fminsearch')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = fminsearch(varargin)
  
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
      error('The second input to fminsearch should be a plist');
    end
    ipl = varargin{2};
  end
  
  % some basic checks
  if numel(f.inputs) > 1
    error('mfh/fminsearch can only minimise a function of one variable');
  end
  
  % apply defaults
  pl = applyDefaults(getDefaultPlist(), ipl);
  
  % get inputs
  p0 = pl.find_core('p0');
  if isempty(p0)
    p0 = copy(f.paramsDef, 1);
  end
  
  if ~isa(p0, 'pest')
    error('Please specify your initial guess in the form of a pest object');
  end
  
  % create function handle
  fh_str = f.function_handle();
  
  % declare objects locally
  declare_objects(f);
  
  % create function handle
  fh = eval(fh_str);
  
  % Apply a negative sign?
  if pl.find_core('apply negative');
    fh = @(p) -fh(p);
  end
  
  % minimise
  opts = pl.find_core('options');
  
  % Evaluate function handle in order to check it
  try
    if ~f.numeric
      fh(p0);
    else
      fh(double(p0));
    end
  catch Me
    error('The evaluation of the function handle failed. Please check it again. Error: [%s]', Me.message)
  end
  
  % call fminsearch wrapper
  [X, Xhist, Fhist] = dosearch(fh, p0, pl, f, opts);
    
  % create output object
  out = p0.copy(1);
  out.setY(X);
    
  % get error
  model = pl.find_core('model');
  dstep = pl.find_core('dstep');
  
  if isempty(dstep)
    dstep = out.y.*1e-4;
  end
  
  if ~isempty(model)
    mseobj = fh(out.y);
    if isa(mseobj,'ao')
      mseobj = mseobj.y;
    end
    % try to estimate the errors - this can fail in some cases (due to rank
    % deficiency) so we put this in a try-catch
    try
      out = getFitErrors(model,out,dstep,mseobj);
    catch Me
      warning('Failed to estimate errors [%s]', Me.message);
    end
  end
  
  out.setName(sprintf('fminsearch(%s)', f.name));
  
  
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
% Fminsearch wrapper
%--------------------------------------------------------------------------
function [X, Xhist, fHist] = dosearch(fh, p0, pl, f, opts)
  
  % initialize histories
  Xhist = [];
  fHist = [];
  
  paramNames = p0.names;
  funcName   = f.name;
  funcStr    = f.func;
  
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
      '%% Log file for mfh/fminsearch, executed %s\n',...
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
  if isempty(opts)
  opts = optimset(opts, ...
      'Display', pl.find_core('display'), ...
      'MaxIter', pl.find_core('maxiter'), ...
      'TolX', pl.find_core('tolx'),...
      'OutputFcn',@outFcn);
  end
  
  X = fminsearch(fh,double(p0),opts);
  
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
  
  % p0
  p = param({'p0', 'Array of initial parameter values. If empty, an array of ones of the appropriate length will be used.'}, []);
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
  
  % Parameters for error calculation
  
  % Model Function
  p = param({'model', 'Model function handle. If left empty we do not provide error.'}, []);
  pl.append(p);
  
  % Derivative step
  p = param({'dstep', 'Vector with derivative steps for each parameter.'}, []);
  pl.append(p);
  
  % Apply negative
  p = param({'Apply negative',['For some cases (like for example a log-likelihood function), a negative sign is added ',...
              'to the numerical value, because the FMINSEARCH is a minimisation algorithm']}, paramValue.FALSE_TRUE);
  pl.append(p);
    
end
