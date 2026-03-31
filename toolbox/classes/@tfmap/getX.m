% GETX Get the property 'x'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'x'.
%
% CALL:        val = obj.getX();
%              val = obj.getX(idx);
%              val = obj.getX(1:10);
%
% We need to override tsdata/getX here because we can have a tfmap where
% the x and y fields are a different length.
%
% INPUTS:      obj - must be a single tsdata object.
%              idx - index of the data samples
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x = getX(obj, idx)
  
  if isempty(obj.xaxis)
    x = [];
    return
  end
  
  ly = length(obj.yaxis.data);
  sx = size(obj.xaxis.data);
  if sx(1) == 0 && sx(2) == 0 && ly>0
    x = tsdata.createTimeVector(obj);
  else
    x = obj.xaxis.data;
  end
  
  % return always a column vector
  if size(x,1) == 1
    x = x.';
  end
  
  % add the toffset
  x = x + obj.toffset / 1000;
  
  if nargin == 2
    if strcmpi(idx, 'end')
      x = x(end);
    else
      x = x(idx);
    end
  end
  
end
