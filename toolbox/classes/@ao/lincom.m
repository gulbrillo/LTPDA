% LINCOM make a linear combination of analysis objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LINCOM makes a linear combination of the input analysis
% objects
%
% CALL:        b = lincom(a1,a2,a3,...,aN,c)
%              b = lincom([a1,a2,a3,...,aN],c)
%              b = lincom(a1,a2,a3,...,aN,[c1,c2,c3,...,cN])
%              b = lincom([a1,a2,a3,...,aN],[c1,c2,c3,...,cN])
%              b = lincom(a1,a2,a3,...,aN,pl)
%              b = lincom([a1,a2,a3,...,aN],pl)
%
%
%              If no plist is specified, the last object should be:
%               + an AO of type cdata with the coefficients inside OR
%               + a vector of AOs of type cdata with individual coefficients OR
%               + a pest object with the coefficients
%
% INPUTS:      ai - a list of analysis objects of the same type
%              c  - analysis object OR pest object with coefficient(s)
%              pl - input parameter list
%
% OUTPUTS:     b  - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'lincom')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lincom(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  if nargout == 0
    error('### lincom cannot be used as a modifier. Please give an output variable.');
  end
  
  %%% Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end
    
  % Collect all AOs and plists
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [ps, ps_invars, rest] = utils.helper.collect_objects(rest(:), 'pest', in_names);
  pl                    = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Combine input PLIST with default PLIST
  usepl = applyDefaults(getDefaultPlist(), pl);
  
  % Check inputs
  if numel(ps) > 1
    error('### This method supports only one PEST object.')
  end
  
  % Get the length of the arguments
  aosIdx = cellfun('isclass', varargin, 'ao');
  num_as = cellfun('length', varargin(aosIdx));
  
  coeffHist = [];
  if ~isempty(usepl.find_core('COEFFS'))
    coeffObj = usepl.find_core('COEFFS');
  elseif numel(ps) == 1
    coeffObj = ps;
    coeffHist = ps.hist;
  elseif isa(as(end).data, 'cdata') && as(end).len == numel(as(1:end-1))
    % The last AOs have the coefficients
    coeffObj = as(end);
    coeffHist = coeffObj.hist;
    % Remove the coefficients AOs from the data AOs
    as(end) = [];
  elseif all(num_as == 1) || num_as(end) == sum(num_as(1:end-1))
    % list of single input AOs
    if mod(numel(as), 2) ~= 0
      error('### If you insert a list of AOs must be the number of AOs even.')
    end
    coeffObj = as(numel(as)/2+1:end);
    coeffHist = [coeffObj.hist];
    % Remove the coefficients AOs from the data AOs
    as(numel(as)/2+1:end) = [];
  else
    error('### Incorrect shape of input!');
  end
  
  % Convert coefficient Object to an AO
  if isa(coeffObj, 'ao')
  elseif isa(coeffObj, 'pest')
    coeffObj = coeffObj.find(coeffObj.names{:});
  elseif isnumeric(coeffObj)
    coeffObj = ao(coeffObj);
  else
    error('### Unsupported data type ''%s'' of the coefficient.', class(coeffObj));
  end
  
  % Checks that coefficients are cdata AO(s)
  for kk = 1:numel(coeffObj)
    if ~isa(coeffObj(kk).data, 'cdata')
      error('### lincom can not be used on this data type.');
    end
  end
  coeffs = coeffObj.y;
  cunits = unit.initObjectWithSize(1, numel(coeffs));
  if numel(coeffObj) == 1
    % Single coefficients AO, get the unit and make copies
    for kk = 1:numel(coeffs)
      cunits(kk) = unit(coeffObj.yunits);
    end
  else
    % Array of coefficients AOs, get each unit separately
    cunits = unit(coeffObj.yunits);
  end
  
  na = length(as);
  nc = length(coeffs);
  if na ~= nc
    disp(sprintf('Num AOs input: %d', na));
    disp(sprintf('Num Coeffs input: %d', nc));
    error('### specify one coefficient per analysis object.');
  end
  
  % Make linear combination, collect name string, compute the new units
  nstr = '';
  y   = zeros(size(as(1).y));
  dy2 = zeros(size(as(1).y));
  
  for kk = 1:nc
    nstr = [nstr num2str(coeffs(kk)) '*' ao_invars{kk} ' + '];
    y =  y + coeffs(kk) .* as(kk).y;
    if ~isempty(as(kk).dy) 
      dy2 = dy2 + (coeffs(kk) .* as(kk).dy).^2;
    end
    new_units(kk) = simplify(as(kk).yunits .* cunits(kk), plist('Prefixes', false));
  end
  nstr = deblank(nstr(1:end-2));
  for kk = 1:nc-1
    [new_units_val(kk), new_units_scale(kk)] = new_units(kk).toSI;
    [new_units_val(kk+1), new_units_scale(kk+1)] = new_units(kk+1).toSI;
    if ~isequal(new_units_val(kk), new_units_val(kk+1)) || ~isequal(new_units_scale(kk), new_units_scale(kk+1))
      error('### inconsistent units in data/coefficients');
    end
  end
  
  % create new ao
  b = ao;
  b.data = copy(as(1).data, 1);
  b.data.setY(y);
  b.data.setDy(sqrt(dy2));
  
  %%% Set Name
  b.name = nstr;
  
  %%% Set new Units
  b.data.setYunits(new_units(1));
  
  %%% Propagate 'plotinfo'
  plotinfo = [as(:).plotinfo];
  if ~isempty(plotinfo)
    b.plotinfo = combine(plotinfo);
  end
  
  %%% Add History
  b.addHistory(getInfo('None'), usepl, [ao_invars ps_invars], [as.hist coeffHist]);
  
  % Set output
  varargout{1} = b;
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
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
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
  pl = plist(...
    {'COEFFS',['A vector of AOs of type cdata with individual coefficients<br>' ...    
    'or a PEST containing a vector of coefficients<br>' ...
    'or a vector of numeric coefficients.']}, paramValue.EMPTY_DOUBLE);
end
% END


