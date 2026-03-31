% GETSELECTIONFORPARAM Returns the selection mode for the specified parameter key.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETSELECTIONFORPARAM Returns the selection mode for the
%              specified parameter key.
%
% CALL:        obj = obj.getSelectionForParam('key');
%              obj = obj.getSelectionForParam(plist('key'));
%              obj = getSelectionForParam(obj, 'key');
%
% INPUTS:      obj - can be a vector, matrix, list, or a mix of them.
%              key - Parameter key
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'getSelectionForParam')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getSelectionForParam(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargin ~= 2
    error('### This method works only with two inputs (plist + key name).');
  end
  if ~(isa(varargin{1}, 'plist') || numel(varargin{1} ~= 1))
    error('### This method accepts only one plist as an input.')
  end
  if ~(ischar(varargin{2}) || isa(varargin{2}, 'plist'))
    error('### The second input must be a ')
  end
  
  pl  = varargin{1};
  key = varargin{2};
  val = [];
  
  if isa(key, 'plist')
    key = key.find_core('key');
  end
  
  for ii = 1:pl.nparams
    if any(strcmpi(pl.params(ii).key, key))
      if isa(pl.params(ii).val, 'paramValue')
        val = pl.params(ii).val.selection;
      else
        % Return -1 for the case that the value is not stored in a
        % paramValue object
        val = -1;
      end
      break;
    end
  end
  
  % Single output
  varargout{1} = val;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = getDefaultPlist()
  
  pl = plist();
  
  % Key
  p = param({'key', 'The key of the parameter to retrieve the selection mode from.'}, paramValue.EMPTY_STRING);
  pl.append(p);  
  
end
