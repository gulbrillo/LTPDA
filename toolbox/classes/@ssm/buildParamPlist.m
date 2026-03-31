% BUILDPARAMPLIST builds paramerter plists for the ssm params field.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: BUILDPARAMPLIST builds paramerter plists for the ssm params
%              field.
%
% CALL:   pl = bode(names, values, descriptions, units, pl)
%
% INPUTS:
%         'names' - (array of) char
%         'values'  - double array of same size
%         'description'  - cellstr of same size
%         'pl'  - plist containing optionnal fields 'min', 'max', 'sigma',
%                 double arrays of same size
%
% OUTPUTS:
%
%        'pl' - plist of ssm parameters.
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'buildParamPlist')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = buildParamPlist(varargin)
  %% starting initial checks
  
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  names = varargin{1};
  value = varargin{2};
  description = varargin{3};
  units = varargin{4};
  pl = varargin{5};
  
  
  %% checking for fields class
  if isa(names, 'char')
    names = {names};
  elseif ~iscellstr(names)
    error('error because names must either be a cellstr or a char')
  end
  Nparams = numel(names);
  
  if ~isa(value, 'double') && ~isempty(value)
    error('error because values must be a double')
  end
  
  if isa(description, 'char')
    description = {description};
  elseif ~iscellstr(description) && ~isempty(description)
    error('error because description must either be a cellstr or a char')
  end
  
  if ~isa(units, 'unit') && ~isempty(units)
    error('error because units must be a unit')
  end
  
  if ~isa(pl, 'plist') && ~isempty(pl)
    error('error because pl must be a plist')
  end
  
  %% checking for empty fields or retrieving data
  if isempty(units)
    dounits = false;
  else
    dounits = true;
    if ~( Nparams==numel(units))
      error('error because names and units are not the same length')
    end
  end
  
  if isempty(description)
    dodescription = false;
  else
    dodescription = true;
    if ~ ( Nparams==numel(description))
      error('error because names and description are not the same length')
    end
  end
  
  if isempty(value)
    value = NaN(1,Nparams);
  else
    if ~ ( Nparams==numel(value))
      error('error because names and value are not the same length')
    end
  end
  
  domax = false;
  domin = false;
  dosigma = false;
  if ~isempty(pl)
    if isparam_core(pl, 'max')
      max = find(pl, 'max');
      domax = true;
      if ~ ( Nparams==numel(max))
        error('error because names and max are not the same length')
      end
    end
    if isparam_core(pl, 'min')
      min = find(pl, 'min');
      domin = true;
      if ~ ( Nparams==numel(min))
        error('error because names and min are not the same length')
      end
    end
    if isparam_core(pl, 'sigma')
      sigma = find(pl, 'sigma');
      dosigma = true;
      if ~ ( Nparams==numel(sigma))
        error('error because names and variance are not the same length')
      end
    end
  end
  
  
  %% building plist
  pl = plist();
  for ii=1:numel(names)
    if dodescription
      pli = plist({names{ii} description{ii}}, value(ii));
    else
      pli = plist(names{ii}, value(ii));
    end
    if domax
      pli.setPropertyForKey(names{ii},'max',max(ii) );
    end
    if domin
      pli.setPropertyForKey(names{ii},'min',min(ii) );
    end
    if dosigma
      pli.setPropertyForKey(names{ii},'sigma',sigma(ii) );
    end
    if dounits
      pli.setPropertyForKey(names{ii},'units',units(ii) );
    end
    pl.append(pli);
  end
  
  varargout{1} = pl;
end

