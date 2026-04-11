% GETOBJECTBYNAME returns an inside object selected by the name.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETOBJECTBYNAME returns an inside object selected by the name.
%              This method is only necessary for collection methods because
%              'subsasgn' and 'subsref' doesn't work inside the class.
%
% CALL:        obj = getObjByName(single-collection)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getObjectByName(collIn, nameIn)
  
  if numel(collIn) ~= 1
    error('This method works only with one input collection object');
  end
  % Get index to the inside object
  idx = strcmp(collIn.names, nameIn);
  out = [collIn.objs{idx}];
  
end

