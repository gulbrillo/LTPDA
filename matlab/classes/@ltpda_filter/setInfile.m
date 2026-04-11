% SETINFILE Set the property 'infile'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETINFILE Set the property 'infile'
%
% CALL:        obj = obj.setInfile('file');
%              obj = setInfile(obj, 'file');
%
% INPUTS:      obj - is a ltpda_filter object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = setInfile(obj, val)
  %%% decide whether we modify the ltpda_filter-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'infile'
  obj.infile = val;
end

