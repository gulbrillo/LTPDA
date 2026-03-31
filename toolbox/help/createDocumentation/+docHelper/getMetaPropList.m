% GETMETAPROPLIST Returns a list of meta-property objects of an meta-class object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Returns a list of meta-property objects of an meta-class
%              object. MATLAB have changed the structure from 'Properties'
%              to 'PropertyList'
%
% CALL:        docHelper.(metaClass)
%
% INPUT:       metaClass - objects from the meta class.
%                          (e.g. meta.class.fromName('ao'))
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function m = getMetaPropList(metaClass)
  
  if ~isa(metaClass, 'meta.class')
    error('### The input object must be a ''meta.class'' object but it is from the type [%s]', class(metaClass));
  end
  
  if isprop(metaClass, 'PropertyList')
    m = metaClass.PropertyList;
  else
    m = [metaClass.Properties{:}];
  end
  
end
