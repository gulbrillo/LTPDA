% GT overloads > operator for timespan objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GT overloads > operator for timespan objects
%
% CALL:        a = ts1 > ts2;
%
% INPUTS:      ts1 - timespan object
%              ts2 - timespan object, time object or a number
%
% OUTPUTS:     a - two logical values from the comparison to the start- and
%                  end-time. The result of multiple timespan objects are
%                  collected in rows.
%
% EXAMPLE:     ts1 = timespan(0000, 1000)
%              ts2 = timespan(1000, 2000)
%              ts3 = timespan(2000, 3000)
%              tss = [ts1, ts2 ts3];
%              t   = time(1500)
%
%              a  = tss > t
%              a =
%                   0     0
%                   0     1
%                   1     1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = gt(varargin)
  
  % Check the number of inputs
  if nargin ~= 2
    error('### This method works only for two inputs. But you have used %d inputs.', nargin)
  elseif ~isa(varargin{1}, 'timespan')
    error('### The first input must  be a timespan-object.')
  elseif ~(isa(varargin{2}, 'timespan') || isa(varargin{2}, 'time') || isnumeric(varargin{2}))
    error('### The second input must  be a timespan-, time-object or a double.')
  elseif numel(varargin{2}) ~= 1 && numel(varargin{2}) ~= numel(varargin{1})
    error('### The number of the second inputs must be one or the same number of the first inputs %d <-> %d.', numel(varargin{1}), numel(varargin{2}));
  else
    obj1 = varargin{1};
    obj2 = varargin{2};
  end
  
  % Compare the number of seconds since the epoch
  if isa(obj2, 'timespan')
    o1 = [obj1.startT] > [obj2.startT];
    o2 = [obj1.endT]   > [obj2.endT];
  else
    o1 = [obj1.startT] > obj2;
    o2 = [obj1.endT]   > obj2;
  end
  out = [o1' o2'];
end
