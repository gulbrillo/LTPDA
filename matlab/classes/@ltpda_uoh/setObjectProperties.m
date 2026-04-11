% SETOBJECTPROPERTIES sets the object properties of an ltpda_uoh object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETOBJECTPROPERTIES sets the object properties of an
%              ltpda_uoh object from the input plist. 
% 
% Only the keys in plist which are actually object properties are used;
% other keys are ignored.
%
% CALL:        objs.setObjectProperties(pl);
%              objs.setObjectProperties(pl, exceptions);
%
% 'exceptions' should be a cell-array of property names which will be
% ignored (not set).
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'setObjectProperties')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setObjectProperties(varargin)

  % Get inputs
  as = varargin{1};
  pl = varargin{2};
  
  if nargin > 2
    exceptions = varargin{3};
  else
    exceptions = {};
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Loop over ltpda_uoh objects
  props = properties(as);
  keys  = pl.getKeys;
  
  for kk = 1:numel(keys)
    key = lower(keys{kk});
    if utils.helper.ismember(key, exceptions)

    elseif utils.helper.ismember(key, lower(props))
      idxProp = utils.helper.ismember(lower(props), key);
      fcn = props{idxProp};
      fcn = ['set' upper(fcn(1)) fcn(2:end)];
      if any(strcmp(fcn, methods(bs)))
        feval(fcn, bs, pl.find_core(key));
      end
    end
    
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

