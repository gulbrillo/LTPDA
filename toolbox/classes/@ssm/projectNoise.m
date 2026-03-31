% PROJECTNOISE performs actions on ao objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PROJECTNOISE performs a component noise projection on SSM
% models. The noise projection can be done either in the frequency domain
% (faster) or the time domain (slower), but the former does not preserve
% phase relations between multiple outputs.
%
%
% CALL:        out = obj.subsData(pl)
%              out = projectNoise(objs, pl)
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input SSM object(s)
%
% OUTPUTS:     out - a collection of noise projetion outputs
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'projectNoise')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = projectNoise(varargin)
  
  % Determine if the caller is a method or a user
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Print a run-time message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names for storing in the history
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all objects of class ssm
  [mods, obj_invars] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pls, pl_invars] = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % determine the set of keys we are using: the set is just the specified
  % mode, or Default
  pl_in = combine(pls);
  method = pl_in.find('Method');
  if isempty(method) || strcmpi(method, 'time')
    set = 'Time';
  else
    set = method;
  end
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist(set), varargin{:});
  
  if isempty(method)
    method = pl.find('Method');
  end
  
  % get inputs for models
  for ii = 1:numel(mods)
    modelPortNames{ii} = mods(ii).getPortNamesForBlocks({mods(ii).inputs.name},plist('type','inputs'));
  end
  
  
  % Find inputs
  inputList = pl.find('Inputs');
  inputNames = {};
  % switch through class of inputs
  switch class(inputList)
    % cell array
    case 'cell'
      % still a few possibilities
      switch class(inputList{1})
        % it was a 1D or 2D array of strings
        case {'char','cell'}
          for ii = 1:numel(mods)
            for jj = 1:size(inputList,2)
              inputNames{ii}{jj} = matchNames(modelPortNames{ii},inputList{jj});
            end
          end
          % it was a cell-array of ssmports
        case 'ssmport'
          for ii = 1:numel(mods)
            for jj = 1:size(inputList,2)
              inputNames{ii}{jj} = {inputList{jj}.name};
            end
          end
          % or we don't know
        otherwise
          error('Unrecognized input port list specification');
      end
      % array of SSM ports
    case 'ssmport'
      for ii = 1:numel(mods)
        for jj = 1:size(inputList,2)
          inputNames{ii,jj} = {inputList{jj}.name};
        end
      end
      
    otherwise
      error('Unrecognized input port list specification');
  end
  
  % Find Input Labels
  inputLabels = pl.find('Input Labels');
  if isempty(inputLabels)
    for ii = 1:numel(mods)
      for jj = 1:length(inputNames{ii})
        inputLabels{jj} = ['Input ' num2str(jj,'%02i')];
      end
    end
  end
  
  % Find Outputs
  outputList = pl.find('Outputs');
  if isempty(outputList)
    error('At least one output must be specified!');
  end
  outputNames = {};
  switch class(outputList)
    % just keep the cell array
    case 'cell'
      outputNames = outputList;
      % extract the name from the ssmport
    case 'ssmport'
      outputNames = {outputList.name};
    otherwise
      error('unrecognized output port list');
  end
  
  % find output ports (for units, kind of kludgy)
  for ii = 1:numel(mods)
    for jj = 1:length(outputNames)
      for kk = 1:length(mods(ii).outputs)
        for ll = 1:length(mods(ii).outputs(kk).ports)
          if strcmpi(outputNames{jj},mods(ii).outputs(kk).ports(ll).name)
            outputPorts(ii,jj) = mods(ii).outputs(kk).ports(ll);
          end
        end
      end
    end
  end
  
  
  % Switch over calculation mode
  switch lower(method)
    % do simulation in time domain
    case 'time'
      utils.helper.msg(msg.PROC3, 'Computing noise projection in time domain');
      % get number of seconds
      nsecs = pl.find('nsecs');
      % determine number of samples
      nsamp = round(nsecs./[mods.timestep]);
      % loop over models
      for ii = 1:numel(mods)
        % loop over projections
        for jj = 1:length(inputLabels)
          utils.helper.msg(msg.PROC3, 'Computing projection of noise %s in model %s', inputLabels{jj}, mods(ii).name);
          % setup simulation
          simpl = plist(...
            'CPSD VARIABLE NAMES',inputNames{ii}{jj},...
            'CPSD',eye(length(inputNames{ii}{jj})),...
            'RETURN OUTPUTS',outputNames,...
            'NSAMPLES',nsamp(ii));
          % simulate
          simOut = simulate(mods(ii),simpl);
          for kk = 1:length(outputNames)
            outData(ii,jj,kk) = simOut.getObjectAtIndex(kk);
            % set the name
            outData(ii,jj,kk).setName(...
              sprintf('projectNoise[%s](%s -> %s)',...
              mods(ii).name,inputLabels{jj},outputNames{kk}));
          end
        end
      end
      
      % do simulation in frequency domain
    case 'frequency'
      utils.helper.msg(msg.PROC3, 'Computing noise projection in frequency domain');
      % first check for explicit frequency vector
      f = pl.find('F');
      % if no explicit vector, then build from parts
      if isempty(f)
        F1 = pl.find('F1');
        F2 = pl.find('F2');
        N = pl.find('N');
        spacing = pl.find('SPACING');
        % build freuqnecy vector
        switch lower(spacing)
          case 'lin'
            f = linspace(F1,F2,N);
          case 'log'
            f = logspace(log10(F1),log10(F2),N);
        end
        % still need F1
      else
        F1 = min(f);
      end
      
      % loop over models
      for ii = 1:numel(mods)
        %loop over projections
        for jj = 1:length(inputLabels)
          utils.helper.msg(msg.PROC3, 'Computing projection of noise %s in model %s', inputLabels{jj}, mods(ii).name);
          %setup bode
          bpl = plist(...
            'inputs', inputNames{ii}{jj},...
            'outputs',outputNames,...
            'F',f);
          % compute frequency response
          bodeOutTmp = bode(mods(ii),bpl);
          % add across outputs (this should really be a method for the
          % matrix class)
          for kk = 1:bodeOutTmp.nrows
            bodeOut = abs(bodeOutTmp.getObjectAtIndex(kk,1)).^2;
            for ll = 2:bodeOutTmp.ncols
              bodeOut = bodeOut + abs(bodeOutTmp.getObjectAtIndex(kk,ll)).^2;
            end
            %             % assume uncorrelated noise between each contribution and scale
            %             % for unit variance white noise input
            %
            %             fs = ao(cdata(1.0/mods(ii).timestep));
            %             fs.setYunits('Hz');
            %
            %             bodeOut = sqrt(bodeOut*2./(fs*bodeOutTmp.ncols));
            outData(ii,jj,kk) = sqrt(bodeOut);
            
            % apply units (for some reason they seem to be lost during
            % ssm/bode)
            % set frequency units
            outData(ii,jj,kk).setXunits('Hz');
            outData(ii,jj,kk).setYunits(outputPorts(ii,kk).units*unit('Hz^-0.5'));
            
            % set the name
            outData(ii,jj,kk).setName(...
              sprintf('projectNoise[%s](%s -> %s)',...
              mods(ii).name,inputLabels{jj},outputNames{kk}));
            
          end
        end
      end
      
      % unknown method
    otherwise
      error('unsupported method');
  end
  
  % pack output data into array of matricies
  for ii = 1:numel(mods)
    out(ii) = matrix(squeeze(outData(ii,:,:)));
    
    % Add history
    if ~callerIsMethod
      out(ii).addHistory(getInfo('None'), pl, obj_invars(ii), out(ii).hist);
    end
    
    % Add name
    out(ii).setName(['projectNoise[',mods(ii).name,']']);
    
  end
  
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
end


%--------------------------------------------------------------------------
% Funciton for picking out all matching names
%--------------------------------------------------------------------------
function namesOut = matchNames(allNames,searchNames)
  
  % convert to single-element cell array if a string
  if ischar(searchNames), searchNames = {searchNames}; end
  
  % pull out names of interest
  keep = [];
  kk = 0;
  for ii = 1:length(allNames)
    % look for match
    ismatch = false;
    for jj = 1:length(searchNames)
      if strfind(allNames{ii},searchNames{jj}), ismatch = true; end
    end
    % if match, flag
    if ismatch
      kk = kk+1;
      keep(kk) = ii;
    end
  end
  
  % keep names
  namesOut = allNames(keep);
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pl = getDefaultPlist(sets{1});
  else
    sets = SETS();
    % get plists
    pl(size(sets)) = plist;
    for kk = 1:numel(sets)
      pl(kk) =  getDefaultPlist(sets{kk});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end


%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  out = {...
    'Time', ...
    'Frequency' ...
    };
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist(varargin)
  persistent pl;
  persistent lastset;
  
  if nargin == 1, set = varargin{1}; else set = 'time'; end
  
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  % Create empty plsit
  pl = plist();
  
  % Method
  p = param(...
    {'Method',['Method to use for computing noise projection.<ul>'...
    '<li>Time - Time domain simulation for each individual component</li>'...
    '<li>Frequency - Fourier Domain noise projection</li></ul>']},...
    {1, {'Time', 'Frequency'}, paramValue.SINGLE});
  pl.append(p);
  
  % Component Inputs
  p = param(...
    {'Inputs',['Input signal blocks for each component to be projected. Can be<ul>'...
    '<li>1D Array of ssmport objects - project each port individually</li>'...
    '<li>Cell array of arrays of ssmport objects - for each cell element, project all ports in array simultaneously</li>'...
    '<li>1D Cell array of strings - for each element, project all ports with matching name strings </li>'...
    '<li>2D Cell array of strings - for each row, project all ports with a name string matching any of the columns </li></ul>']},...
    paramValue.EMPTY_CELL);
  pl.append(p);
  
  % Input Labels
  p = param(...
    {'Input Labels',['Cell array of strings for labeling inputs']},...
    paramValue.EMPTY_CELL);
  pl.append(p);
  
  % Outputs
  p = param(...
    {'Outputs',['Output signal block(s). Can be<ul>'...
    '<li>1D array of ssmport objects<\li>',...
    '<li>Cell array of port names<\li>',...
    '<li>String for single port name<\li><\ul>']},...
    paramValue.EMPTY_CELL);
  pl.append(p);
  
  
  % go through parameter sets
  switch lower(set)
    % Default is Constant value(s)
    case 'time'
      % NSECS
      p = param(...
        {'nsecs', ['Number of seconds to run the simulation']},...
        paramValue.DOUBLE_VALUE(1e4)...
        );
      pl.append(p);
      
      % Mean
    case 'frequency'
      % parameter 'F_START'
      p = param({'F_START', ['Starting frequency ']}, ...
        paramValue.DOUBLE_VALUE(1e-4));
      p.addAlternativeKey('F1');
      pl.append(p);
      
      % parameter 'F_STOP'
      p = param({'F_STOP', ['Stoping frequency ']}, ...
        paramValue.DOUBLE_VALUE(1e-1));
      p.addAlternativeKey('F2');
      pl.append(p);
      
      % parameter 'N'
      p = param({'N', ['Number of frequency points']}, ...
        paramValue.DOUBLE_VALUE(512));
      pl.append(p);
      
      % parameter 'Spacing'
      p = param({'SPACING', ['frequency spacing']}, ...
        {1, {'log', 'lin'}, paramValue.SINGLE});
      pl.append(p);
      
      % Frequency vector
      p = param({'F', ['Frequency vector']},paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % otherwise
    otherwise
      error('Unsuported set [%s]',set);
  end
end
