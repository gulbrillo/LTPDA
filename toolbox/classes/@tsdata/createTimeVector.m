% createTimeVector Creates the time-series vector from the given 'fs' and 'nsecs'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: createTimeVector Creates the time-series vector from the
%              given 'fs' and 'nsecs'.
%
% CALL:        t = tsdata.createTimeVector(fs, nsecs);
%              t = tsdata.createTimeVector(obj);
%
% INPUTS:      fs    - Sample rate of the time-series
%              nsecs - the length of this time-series in seconds
%            or
%              obj   - tsdata object
%
% OUTPUT:      t     - column vector
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t = createTimeVector(varargin)
  
  if nargin == 1
    obj =varargin{1};
    fs    = obj.fs;
    nsecs = obj.nsecs;
  else
    fs    = varargin{1};
    nsecs = varargin{2};
  end
  
  % We had in the past two different equations:
  %
  %   x = linspace(0, obj.nsecs-1/obj.fs, obj.nsecs*obj.fs);
  %   x = 0:1/fs:nsecs-1/fs;
  %
  % The issue was/is that all three equations produce different t vectors.
  % But by having this static method is it easy to change the equation
  % easily.
  t = (0:(nsecs*fs-1)).'/fs;
  
end

