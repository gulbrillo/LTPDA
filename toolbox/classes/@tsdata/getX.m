% GETX Get the property 'x'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'x'.
%
% CALL:        val = obj.getX();
%              val = obj.getX(idx);
%              val = obj.getX(1:10);
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
  ts = 1/obj.fs;
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
  
  % We can have rounding errors for strange sample rates and Nsecs
  if length(x) < ly
    while length(x) < ly
      x = [x; x(end)+ts];
    end
  end
  
  if length(x) ~= ly
    x = x(1:ly);
  end
  
  if nargin == 2
    if strcmpi(idx, 'end')
      x = x(end);
    else
      x = x(idx);
    end
  end
  
end

