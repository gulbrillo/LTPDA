% RESP returns the complex response of a transfer function as an Analysis Object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESP returns the complex response of a transfer function as
%              an Analysis Object.
%
% CALL:        a = resp(obj, f);          % compute response for vector f
%              a = resp(obj, f1, f2, nf); % compute response from f1 to f2 in nf
%                                           steps.
%              a = resp(obj, pl);         % compute response from parameter list.
%              a = resp(obj);             % compute response
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_tf', 'resp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = resp(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %%% Input objects checks
  if nargin < 1
    error('### incorrect number of inputs.')
  end
  
  objs = {};
  rest = {};
  plin = [];
  invars = {};
  % Check input shape
  % only one input -> keep shape
  % more than one input -> convert to list.
  classMatch = zeros(nargin, 1);
  for ii = 1:nargin
    if isa(varargin{ii}, 'ltpda_tf')
      classMatch(ii) = 1;
    end
  end
  
  for ii = 1:nargin
    if classMatch(ii) == 1
      if sum(classMatch) == 1
        objs = num2cell(varargin{ii});
        invars = [invars repmat({inputname(ii)}, 1, numel(varargin{ii}))];
      else
        objs = [objs reshape(num2cell(varargin{ii}), 1, [])];
        invars = [invars repmat({inputname(ii)}, 1, numel(varargin{ii}))];
      end
    else
      if isa(varargin{ii}, 'plist')
        plin = [plin varargin{ii}];
      else
        rest = [rest {varargin{ii}}];
      end
    end
  end
    
  % Combine the input plists
  if ~callerIsMethod
    plin = combine(plin, plist());
  else
    if isempty(plin)
      plin = plist();
    end
  end
  
  % Initialize output
  if isempty(plin.find_core('bank'))
    bs = ao.initObjectWithSize(size(objs,1), size(objs,2));
    bank = 'None';
  else
    bank = plin.combine(getDefaultPlist('Range')).find_core('bank');
    switch lower(bank)
      case 'none'
        bs = ao.initObjectWithSize(size(objs,1), size(objs,2));
      otherwise
        bs = [];
    end
  end
  
  
  % Loop over transfer functions
  for pp=1:numel(objs)
    
    % process this transfer function
    obj = objs{pp};
    % Now look at the model
    name  = obj.name;
    
    if (plin.isparam_core('f')) || ...
        (numel(rest) == 1 && isnumeric(rest{1}) && isvector(rest{1})) || ...
        (numel(rest) == 1 && isa(rest{1}, 'ao') && isa(rest{1}.data, 'fsdata')) || ...
        (numel(rest) == 1 && isa(rest{1}, 'ao') && isa(rest{1}.data, 'xydata'))
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%              Response with a f vector               %%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%% r = obj.resp(plist-object('f'))
      %%% r = obj.resp(ao-object(fsdata))
      %%% r = obj.resp(ao-object(xydata))
      
      % list plist
      if ~callerIsMethod
        pl = applyDefaults(getDefaultPlist('List'), plin);
      else
        pl = plin;
      end
            
      if numel(rest) == 1
        pl.pset('f', rest{1});
      end
      
      %%% Get f-vector
      f = pl.find_core('f');
      
      %%% Get the f-vector from the AO
      if isa(f, 'ao')
        f = f.data.x;
      elseif isnumeric(f) && isvector(f)
        %%% nothing to do
      else
        error('### The f-vector must be a vector or an AO, but it is from the class [%s]', class(f));
      end
      
    elseif (plin.isparam_core('f1')) || ...
        (plin.isparam_core('f2'))    || ...
        (numel(rest) == 0)      || ...
        (numel(rest) == 2 && isnumeric(rest{1}) && isnumeric(rest{2})) || ...
        (numel(rest) == 3 && isnumeric(rest{1}) && isnumeric(rest{2}) && isnumeric(rest{3}))
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%             Response with f1, f2 and nf             %%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%% r = obj.resp(plist-object('f1', 'f2'))
      %%% r = obj.resp(plist-object('f1'))
      %%% r = obj.resp(plist-object('f2'))
      %%% r = obj.resp()
      %%% r = obj.resp(f1, f2)
      %%% r = obj.resp(f1, f2, nf)
      
      if numel(rest) == 0 && plin.nparams == 0
        pl = getDefaultPlist('Range');
        
      elseif numel(rest) == 2
        pl = applyDefaults(getDefaultPlist('Range'), plist('f1', rest{1}, 'f2', rest{2}));
        
      elseif numel(rest) == 3
        pl = applyDefaults(getDefaultPlist('Range'), plist('f1', rest{1}, 'f2', rest{2}, 'nf', rest{3}));
        
      else
        pl = applyDefaults(getDefaultPlist('Range'), plin);
      end
      
      f1 = pl.find_core('f1');
      f2 = pl.find_core('f2');
      nf = pl.find_core('nf');
      scale = pl.find_core('scale');
      
      % Get the default values if 'f1' or 'f2' are not existing
      if isa(obj, 'miir') || isa(obj, 'mfir')
        % Special case for iir- and fir filters.
        if isempty(f1), f1 = obj.fs/1000; end
        if isempty(f2), f2 = obj.fs/2-1/nf; end
        if isempty(f1), f1 = 0; end
        if isempty(f2), f2 = 0.5; end
        
      else
        if isempty(f1), f1 = getlowerFreq(obj)/10; end
        if isempty(f2), f2 = getupperFreq(obj)*10; end
      end
      
      switch lower(scale)
        case 'lin'
          f = linspace(f1, f2, nf);
        case 'log'
          f = logspace(log10(f1), log10(f2), nf);
      end
      
    else
      error('### Unknown or incorrect number of inputs.');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%                    deal with rows                     %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    reshape_f = false;
    if size(f,1) > 1
      f = f.';
      reshape_f = true;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%                 compute the response                  %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    r = respCore(obj, f);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%                   Build output AO                     %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if reshape_f
      f = f.';
      r = r.';
    end
    
    % create new output fsdata
    fsd = fsdata(f, r);
    
    % set yunits = ounits./iunits
    fsd.setXunits(unit.Hz);
    if isempty(obj.iunits.strs)
      fsd.setYunits(obj.ounits);
    else
      fsd.setYunits(obj.ounits./obj.iunits);
    end
    
    % set fs, if the object is a discrete filter
    if isa(obj, 'ltpda_filter')
      fsd.setFs(obj.fs);
    end
    
    % make output analysis object
    b = ao(fsd);
    
    % make sure we copy the plotinfo objects
    if isa(obj.plotinfo, 'ltpda_obj')
      b.plotinfo = copy(obj.plotinfo, 1);
    end
    
    switch lower(bank)
      case 'none'
        if ~callerIsMethod
          % Add history
          b.addHistory(getInfo('None'), pl, invars, obj.hist);
          % set name
          if isempty(name)
            b.setName(sprintf('resp(%s)', invars{pp}));
          else
            b.setName(sprintf('resp(%s)', name));
          end
          
        end
        
        % Add to outputs
        bs(pp) = b;

      case 'serial'
        if isempty(bs)
          bs = b;
          oname = obj.name;
        else
          bs = bs .* b;
          oname = [oname '.*' obj.name];
        end
        
      case 'parallel'
        if isempty(bs)
          bs = b;
          oname = obj.name;
        else
          bs = bs + b;
          oname = [oname '+' obj.name];
        end
      otherwise
        error('Unknown option for parameter ''bank'': %s', bank);
    end
    
    
  end % End loop over objects
  
  if ~callerIsMethod
    if strcmpi(bank, 'parallel') || strcmpi(bank, 'serial')
      inhists = [];
      for ii = 1:numel(objs)
        inhists = [inhists objs{ii}.hist];
      end
      % Add history
      bs.addHistory(getInfo('None'), pl, [], inhists);
      % set name
      bs.setName(sprintf('resp(%s)', oname));
    end
  end
  
  
  % Outputs
  if nargout == 0
    iplot(bs)
  elseif nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
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
    pls   = [];
  elseif nargin == 1&& ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pls = getDefaultPlist(sets{1});
  else
    sets = {'List', 'Range'};
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
  ii.setModifier(false);
  ii.setArgsmin(1);
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

function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function plo = buildplist(set)
  switch lower(set)
    case 'list'
      
      plo = plist();
      
      p = param({'f',['A vector of frequencies to evaluate at or an AO \n',...
        'whereby the x-axis is taken for the frequency values.']}, paramValue.EMPTY_DOUBLE);
      plo.append(p);
      
    case 'range'
      plo = plist();
      
      p = param({'f1','Start frequency.'}, paramValue.EMPTY_DOUBLE);
      plo.append(p);
      
      p = param({'f2','Stop frequency.'}, paramValue.EMPTY_DOUBLE);
      plo.append(p);
      
      p = param({'nf','Number of evaluation frequencies.'}, paramValue.DOUBLE_VALUE(1000));
      plo.append(p);
      
      p = param({'scale',['Spacing of frequencies:<ul>', ...
        '<li>''lin'' - Linear scale.</li>', ...
        '<li>''log'' - Logarithmic scale.</li></ul>']}, {2, {'lin', 'log'} paramValue.SINGLE});
      plo.append(p);
      
    otherwise
      error('### Unknown set [%s]', set);
  end
  
  p = param({'bank',['How to handle a vector of input filters<br/>(only iir and fir filters):<ul>',...
    '<li>''None''     - process each filter individually.</li>',...
    '<li>''Serial''   - return the response of a serial filter bank.</li>',...
    '<li>''Parallel'' - return the response of a parallel filter bank.</li></ul>']}, {1, {'none', 'serial', 'parallel'}, paramValue.SINGLE});
  plo.append(p);
  
end

