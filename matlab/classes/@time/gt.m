% GT overloads > operator for time objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GT overloads > operator for time objects
% 
% CALL:        a = t1 > t2;
%
% INPUTS:      t1 - time object
%              t2 - time object or a number
%
% OUTPUTS:     a - logical value from the comparison
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = gt(varargin)
  
  % Check the number of inputs
  if nargin ~= 2
    error('### This method works only for two inputs. But you have used %d inputs.', nargin)
  elseif ~isa(varargin{1}, 'time')
    error('### The first input must  be a time-object.')
  elseif ~(isa(varargin{2}, 'time') || isnumeric(varargin{2}))
    error('### The second input must  be a time-object or a double.')
  else
    obj1 = varargin{1};
    obj2 = varargin{2};
  end

  % Compare the number of milliseconds since the epoch
    if isa(obj2, 'time')
      out = [obj1.utc_epoch_milli] > [obj2.utc_epoch_milli];
    else
      out = [obj1.utc_epoch_milli] > obj2*1000;
    end
end
