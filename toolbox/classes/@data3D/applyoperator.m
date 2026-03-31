% APPLYOPERATOR applys the given operator to the two input data objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: APPLYOPERATOR applys the given operator to the two input
%              3D data objects.
%
% CALL:        d = applyoperator(d1, d2, pl)
%
% INPUTS:      d1 - a data3D object (xyzdata)
%              d2 - a data3D or cdata object
%              pl     - a plist of configuration options
%
% PARAMETERS: 'op'     - the operator to apply, e.g. 'power'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = applyoperator(varargin)

  % Get the objects we have in the correct order
  objs = varargin(1:2);

  % Get the operator to apply
  op   = varargin{3};

  if numel(objs) ~= 2
    error('### data3D/applyoperator requires two input data objects to work on.');
  end

  %--------------- Add some rules here.
  % cdata
  %    1) time-base must match
  %    2) y dimensions must match or one must be a single value
  %

  % TODO the rules don't seem to be properly applied here
  
  %%% Decide the type of the output object
  dout = objs{1};
  
  if isa(objs{2}, 'cdata')
    dout.setZ(feval(op, objs{1}.getZ, objs{2}.getY));
  else
    dout.setZ(feval(op, objs{1}.getZ, objs{2}.getZ));
  end
  
  varargout{1} = dout;
end

