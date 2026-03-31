% SETDEFAULTOPTION Sets the default option of the a param object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETDEFAULTOPTION Sets the default option of the a param
%              object. If the option doesn't exist in the options of the
%              param object then this method throws an error.
%
% CALL:        obj = obj.setDefaultOption(option);
%
% INPUTS:      obj    - A single param object
%              option - An option which should to be set.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = setDefaultOption(p, option)
  
  % Check input
  if numel(p) ~= 1
    error('### This method works only with one input parameter object.');
  end
  if ~ischar(option) && isa(option, 'paramValue') && numel(option) ~= 1
    error('### This method works only with one input option.');
  end
  
  if ~isa(p.val, 'paramValue')
    p.val = option;
    return;
  end
  
  % Make a copy if the user doesn't use the modifier command
  p = copy(p, nargout);
  
  found = false;
  for ii = 1:numel(p.val.options)
    
    % Use different compare methods for the different types of 'option'
    switch class(option)
      case 'char'

        % CHAR
        if strcmpi(p.val.options{ii}, option)
          p.val.setValIndex(ii);
          found = true;
          break;
        elseif islogical(p.val.options{ii})
          try
            % We need the try-catch structure to avoid errors from utils.prog.yes2true 
            value = utils.prog.yes2true(option);
            if isequal(p.val.options{ii}, value)
              p.val.setValIndex(ii);
              found = true;
              break;
            end
          end
        end
      
      case 'specwin'
        
        % SPECWIN
        if strcmpi(p.val.options{ii}, option.type)
          p.val.setValIndex(ii);
          found = true;
          break;
        end
        
      case 'paramValue'
        if isequal(p.val.options{ii}, option.options{option.valIndex})
          p.val.setValIndex(ii);
          found = true;
          break;
        end
        
      otherwise
        
        % ALL OTHER TYPES
        if isequal(p.val.options{ii}, option)
          p.val.setValIndex(ii);
          found = true;
          break;
        end
        
    end
  end
  
  if ~found
    % IF the selection mode of the param-object is OPTIONAL then append
    % this new option to the param.options
    if (p.val.selection == paramValue.OPTIONAL)
      newOptions = [reshape(p.val.options, [], 1); {option}];
      p.val.setValIndexAndOptions(numel(newOptions), newOptions);
    else
      % throw an error if the option is not found in the param-options
      error('### The input value [%s] for the parameter [%s] is not supported. Stopping!', utils.helper.val2str(option), utils.helper.val2str(p.key));
    end
  end
  
end

