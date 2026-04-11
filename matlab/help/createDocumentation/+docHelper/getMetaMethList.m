% GETMETAMETHLIST Returns a list of meta-method objects of an meta-class object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Returns a list of meta-method objects of an meta-class
%              object. MATLAB have changed the structure from 'Methods'
%              to 'MethodList'
%
% CALL:        docHelper.(metaClass)
%
% INPUT:       metaClass - objects from the meta class.
%                          (e.g. meta.class.fromName('ao'))
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function m = getMetaMethList(metaClass)
  
  if ~isa(metaClass, 'meta.class')
    error('### The input object must be a ''meta.class'' object but it is from the type [%s]', class(metaClass));
  end
  
  if isprop(metaClass, 'MethodList')
    m = metaClass.MethodList;
  else
    m = [metaClass.Methods{:}];
  end
  
end
