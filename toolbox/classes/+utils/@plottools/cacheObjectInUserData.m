% CACHEOBJECTINUSERDATA cache a copy of the object in the figure handle's
% user data.
% 
% CALL:
%         cacheObjectInUserData(h, obj)
%         cacheObjectInUserData(h, obj, 'replace')
%
% INPUTS:
%         h         - Any graphical handle (figure-, axes-, line-, ... - handle)
%         obj       - Any type of object (LTPDA object, Char, Double, ...)
%         'replace' - Option which replaces the current UserData with 'obj'
% 
function cacheObjectInUserData(h, obj, varargin)
  obj = copy(obj,1);
  udata = get(h, 'UserData');
  if isempty(udata) || ~isempty(varargin)
    udata = {obj};
  else
    udata = [udata {obj}];
  end
  set(h, 'UserData', udata);
end

% END
