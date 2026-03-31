% ISEQUAL overloads the isequal operator for ltpda objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISEQUAL overloads the isequal operator for ltpda objects.
%
%              All fields are checked.
%
% CALL:        result = isequal(obj1,obj2)
%              result = isequal(obj1,obj2,  exc_list)
%              result = isequal(obj1,obj2, 'property1', 'property2')
%              result = isequal(obj1,obj2, '<class>/property', '<class>/property')
%
%              With a PLIST
%
%              r = isequal(obj1, obj2, plist('Exceptions', {'prop1', 'prop2'}))
%              r = isequal(obj1, obj2, plist('Tol', eps(1)))
%              r = isequal(obj1, obj2, plist('Exceptions', 'prop', 'Tol', 1e-14))
%
% EXAMPLES:    result = isequal(obj1,obj2, 'name', 'created')
%              result = isequal(obj1,obj2, '<class>/name')
%
% INPUTS:      obj1, obj2 - Input objects
%              exc_list   - Exception list
%                           List of properties which are not checked.
%
% OUTPUTS:     If the two objects are considered equal, result == true,
%              otherwise, result == false.
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_obj', 'isequal')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = isequal(obj1, obj2, varargin)
  
  if nargout == 2
    [r, m] = ltpda_obj.isequalMain(obj1, obj2, varargin{:});
  else
    r = ltpda_obj.isequalMain(obj1, obj2, varargin{:});
    m = '';
  end
  varargout{1} = r;
  varargout{2} = m;
  
end
