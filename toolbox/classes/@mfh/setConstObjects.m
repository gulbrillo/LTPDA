% SETCONSTOBJECTS sets the 'constObjects' property of a mfh object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETCONSTOBJECTS sets the 'ConstObjects' property of a mfh object.
%
% CALL:       
%              obj = setConstObjects(obj, name, val)
%              obj = setConstObjects(obj, name1, val1, name2, val2,...)
%              obj = obj.setConstObjects(plist('ConstObjects', val);
%              obj = obj.setConstObjects(plist('names', {name1, name2}, 'values', {ao1, ao2});
%
% INPUTS:      obj: mfh object(s)
%              val: Single object or a cell of objects
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'setConstObjects')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setConstObjects(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if callerIsMethod
    in_names = {};
  else
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  end
  
  % Collect all objects
  [mfhs, mfh_invars, rest] = utils.helper.collect_objects(varargin(:), 'mfh', in_names);
  [pls, pl_invars, pairs] = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % apply defaults
  pl = applyDefaults(getDefaultPlist, pls);
  
  % copy 
  inhists = [mfhs.hist];
  mfhs    = copy(mfhs, nargout);
  
  if mod(numel(pairs), 2) ~= 0
    error('When providing name/value pairs, ensure there is one value per name');
  end
  
  % get constants
  constNames   = mfh.prepareConstants(pl.find('names'));  
  constVals    = pl.find('values');  
  constObjects = pl.find('constObjects');  
  
  % process inputs
  if numel(constNames) ~= numel(constVals)
    error('Please provide one value per name when using the ''names'' and ''values'' plist options');
  end
  
  % ensure we have a cell-array of values
  constVals    = valuesToCell(constVals);
  constObjects = valuesToCell(constObjects);

  % collect pairs from plist
  plpairs = reshape([constNames; constVals], 1, []);
  if ~isempty(plpairs)
    pairs = plpairs; % plist wins
  end  
  
  % process each input
  for mm=1:numel(mfhs)
    m = mfhs(mm);
    
    if ~isempty(constObjects)
      
      if numel(constObjects) ~= numel(m.constObjects)
        error('The number of constant values must match the current number in the model');
      end
      
      if ~iscell(constObjects)
        error('Please provide a cell-array of constant values');
      end
      
      % set new constants
      m.constObjects = constObjects;
      
    else
      
      % ensure these are in the history
      pl.pset('names', mfh.prepareConstants(pairs(1:2:end)));
      pl.pset('values', pairs(2:2:end));
      
      % process name/value pairs
      currentNames = cellfun(@char, m.constants, 'UniformOutput', false);
      for kk=1:2:numel(pairs)
        name = char(pairs{kk});
        val  = pairs{kk+1};
        
        idx = find(strcmp(currentNames, name));
        if isempty(idx)
          error('Not settings value for constant named [%s] as it is not found in the model', name);
        end
        
        % check units, if possible
        currentName = m.constants{idx};
        if isa(currentName, 'LTPDANamedItem') && isa(val, 'ao')
          if ~isempty(currentName.units) && ...
              ~isempty(val.yunits) && ...
              ~isequal(currentName.units.toSI, val.yunits.toSI)
            error('Units of new data %s don''t match the definition for this constant %s', char(val.yunits), char(currentName.units));
          end
        end
        
        m.constObjects{idx} = val;        
      end % End loop over pairs
      
    end     
    
    % reset the function handle as we need to re-declare the constants
    m.resetCachedProperties();
      
    % set history
    m.addHistory(getInfo('None'), pl, mfh_invars(mm), inhists(mm));
    
  end % End loop over input models
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, mfhs);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function constVals = valuesToCell(constVals)
  % ensure we have a cell-array of values
  if ~iscell(constVals)
    cellVals = {};
    for kk=1:numel(constVals)
      cellVals{kk} = constVals(kk);
    end
    constVals = cellVals;
  end
end


function ii = getInfo(varargin)
  
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();

  p = param({'names', 'The constant object names to set.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  p = param({'values', 'The constant object values to set.'}, paramValue.EMPTY_CELL);
  pl.append(p);
  
  p = param({'constObjects', 'The constant objects to set.'}, paramValue.EMPTY_CELL);
  p.addAlternativeKey('constant objects');
  p.addAlternativeKey('constant values');
  p.addAlternativeKey('constants');
  pl.append(p);
  
end

