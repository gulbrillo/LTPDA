% FIXNSECS fixes the numer of seconds.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: fixes the numer of seconds.
%
% CALL:        d    = fixNsecs(d)
%
% INPUT:       d - tsdata object
%
% OUTPUT:      d - tsdata object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = fixNsecs(varargin)
  
  obj = varargin{1};
  
  %%% decide whether we modify the time object, or create a new one.
  obj = copy(obj, nargout);
  
  if isempty(obj.xaxis.data)
    % Then the data is evenly sampled and the
    % duration of the data is easily computed.
    obj.nsecs = length(obj.yaxis.data)/obj.fs;
  else
    % Then we have unevenly sampled data and the data duration
    % is taken as x(end) - x(1);
    x = obj.xaxis.data;
    obj.nsecs = abs(x(end) - x(1)) + 1/obj.fs;
  end
  
  varargout{1} = obj;
end

