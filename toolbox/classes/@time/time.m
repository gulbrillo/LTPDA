% TIME Time object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Time object class constructor.  Time objects are lightweight
%              ltpda user objects that can be used to operate with times.
%              Their use in the graphical user interface is limited to
%              their creation.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%       t1 = time()
%       t1 = time('14:00:05.000')
%       t1 = time('2007-06-06 14:00:05')
%       t1 = time('14:00:05 2007-06-06')
%       t1 = time('2015-293')
%       t1 = time('2015-293 04:40')
%       t1 = time(1234.5)
%       t1 = time([0 2000 6000])
%       t1 = time(plist)
% 
% Some supported formats:
%       t1 = time('yyyy-MM-dd HH:mm:ss')
%       t1 = time('yyyy-MM-dd HH:mm')
%       t1 = time('yyyy-DOY')
%       t1 = time('mm:ss')
%       t1 = time('HH:mm:ss')
%
% PLIST CONSTRUCTORS:
%
% From Milliseconds
% -----------------
%
%   Construct a time object from its representation in milliseconds since the
%   unix epoch, 1970-01-01 00:00:00.000 UTC:
%
%     'milliseconds' - time in milliseconds. default: 0
%
% From Time
% ---------
%
%   Construct a time object from its representation as a string or its
%   representation as number of seconds since the unix epoch, 1970-01-01
%   00:00:00.000 UTC:
%
%     'time' - time string or double. default: '1970-01-01 00:00:00.000 UTC'
%
%   If the time is specified as a string it is possible to specify the format
%   and the timezone that must be used to interpret the string:
%
%     'timezone'    - timezone. default: ''
%     'timeformat'  - time format string. default: ''
%
%
% SEE ALSO: timespan
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef time < ltpda_nuo

  % private read-only properties
  properties (SetAccess = private)
    utc_epoch_milli = 0;  % unix epoch time in milliseconds
  end

  % protected properties
  properties (SetAccess = protected)
  end

  % constant properties
  properties (Constant = true)
    timeformat;
    timezone;
  end

  % constant properties access methods
  methods
    function value = get.timezone(obj)
      persistent val
      if isempty(val)
        p = getappdata(0, 'LTPDApreferences');
        val = char(p.getTimePrefs.getTimeTimezone);
        if ischar(val)
          val = java.util.TimeZone.getTimeZone(val);
        end
      end
      value = val;
    end

    function value = get.timeformat(obj)
      persistent val
      if isempty(val)
        p = getappdata(0, 'LTPDApreferences');
        val = char(p.getTimePrefs.getTimestringFormat);
      end
      value = val;
    end
  end
  
  % constructor
  methods
    function obj = time(varargin)

      switch nargin
        case 0
          % no input arguments. return the current time
          obj.utc_epoch_milli = time.now();
        case 1
          % one input

          if isa(varargin{1}, 'time')
            % t1 = time(time-object)
            obj = copy(varargin{1}, 1);

          elseif ischar(varargin{1})
            % t1 = time('2007-08-03 10:00:00')
            obj.utc_epoch_milli = time.parse(varargin{1});

          elseif isstruct(varargin{1})
            % t1 = time(structure)
            obj = fromStruct(obj, varargin{1});

          elseif isnumeric(varargin{1})
            % t1 = time(12345)
            if ~isempty(varargin{1})
              for kk = 1:numel(varargin{1})
                obj(kk).utc_epoch_milli = 1000*varargin{1}(kk);
              end
              obj = reshape(obj, size(varargin{1}));
            end
          elseif iscell(varargin{1})
            % t1 = time({'14:00:00', '15:00:00'})
            for kk = 1:numel(varargin{1})
              obj(kk) = time(varargin{1}{kk});
            end
            obj = reshape(obj, size(varargin{1}));

          elseif isa(varargin{1}, 'plist')
            % t1 = time(plist)
            pl = varargin{1};
            pl_msec = find(pl, 'milliseconds');
            pl_time = find(pl, 'time');

            if ~isempty(pl_msec)
              % construct from milliseconds time definition
              obj.utc_epoch_milli = pl_msec;

            elseif ~isempty(pl_time)
              % construct from numeric value or string
              if ischar(pl_time)
                pl_timezone = find(pl, 'timezone');
                pl_format   = find(pl, 'timeformat');
                obj.utc_epoch_milli = time.parse(pl_time, pl_format, pl_timezone);
              elseif isnumeric(pl_time)
                obj.utc_epoch_milli = 1000*pl_time;
              end

            else
              % if the plist is empty then return the default time object
              if nparams(pl) == 0
                % default time object
              else
                error('### Unknown TIME constructor method.');
              end
            end

          else
            error('### Unknown single argument constructor.');
          end

        case 2
          % two input

          if iscellstr(varargin)
            % t1 = time('14:00:00', 'HH:MM:SS')
            obj.utc_epoch_milli = time.parse(varargin{1}, varargin{2});
            
          elseif isnumeric(varargin{1}) && ischar(varargin{2})
            % t1 = time(1234.5, 'HH:MM:SS')
            % NOTE: this is kept for back compatibility only. the second argument is just ignored
            warning('LTPDA:time', 'time(numeric, char) costructor is deprecated and will be soon removed');
            obj = time(varargin{1});

          elseif isa(varargin{1}, 'time') && ischar(varargin{2})
            % t1 = time(1234.5, 'HH:MM:SS')
            % NOTE: this is kept for back compatibility only. the second argument is just ignored
            warning('LTPDA:time', 'time(time, char) costructor is deprecated and will be soon removed');
            obj = time(varargin{1});
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && isa(varargin{2}, 'history')
            % t1 = time(dom-node, history-objects)
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif ischar(varargin{1}) && isa(varargin{2}, 'plist')
            pl = varargin{2};
            pl_timezone = find(pl, 'timezone');
            pl_format   = find(pl, 'timeformat');
            obj.utc_epoch_milli = time.parse(varargin{1}, pl_format, pl_timezone);
            
          else
            error('### Unknown constructor with two inputs: %s %s.', class(varargin{1}), class(varargin{2}));
          end

        otherwise
          error('### Unknown number of constructor arguments.');
      end

    end
  end

  % public methods
  methods
    varargout = copy(varargin)
    varargout = format(varargin)
    varargout = minus(varargin)
    varargout = plus(varargin)
    varargout = string(varargin)
    varargout = double(varargin)
    varargout = datenum(varargin)
    varargout = min(varargin)
    varargout = max(varargin)
    varargout = mean(varargin)
    varargout = mode(varargin)
  end


  % private methods
  methods (Access = private)
  end
  
  % protected methods
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end

  % static methods
  methods (Static)

    varargout = parse(varargin);
    varargout = getdateform(varargin);
    varargout = matfrmt2javafrmt(varargin);
    varargout = strftime(varargin);
    varargout = getTimezones(varargin)

    function msec = now()
      msec = java.util.Date().getTime();
    end

    function t = fromDOY(doy)
      % FROMDOY creates a time object for the given DOY with the time at
      % midnight UTC of that day.
      %
      % CALL
      %          t = time.fromDOY(doy)
      %
      % Example:
      %          t = time.fromDOY(123)
      %
      %
      
      calendar = java.util.Calendar.getInstance();
      calendar.setTimeZone(java.util.TimeZone.getTimeZone('UTC'));      
      calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
      calendar.set(java.util.Calendar.MINUTE, 0);
      calendar.set(java.util.Calendar.SECOND, 0);
      calendar.set(java.util.Calendar.MILLISECOND, 0);
      calendar.set(java.util.Calendar.DAY_OF_YEAR, doy);
      t = time(calendar.getTimeInMillis/1000);
      
    end
    
    function t = fromGPS(gpsTime)
      % FROMGPS creates a time object from a GPS time
      %
      % CALL
      %          t = time.fromGPS(gpsTime)
      %
      % Example:
      %          t = time.fromGPS(1141594869)
      %
      %
      
      t = time(0)+(gpsTime-time(0).toGPS);
      
    end

    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'time');
    end

    function out = SETS()
      out = {...
        'Default', ...
        'From Milliseconds', ...
        'From Time' };
    end

    function out = getDefaultPlist(set)
      switch lower(set)
        case 'default'
          out = plist();
        case 'from milliseconds'
          out = plist('milliseconds', 0);
        case 'from time'
          out = plist('time', '1970-01-01 00:00:00.000 UTC', 'timezone', '', 'timeformat', '');
        otherwise
          error('### Unknown set ''%s'' to get the default plist.', set);
      end
    end

    function obj = initObjectWithSize(varargin)
      obj = time.newarray([varargin{:}]);
    end

  end % end static methods

  % static hidden methods
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end   

end % end classdef

