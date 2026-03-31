% TSDATA time-series object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TSDATA time-series object class constructor.
%              Create a time-series data object. If the time-series object
%              is determined to be evenly sampled, no x vector is stored.
%
% SUPER CLASSES: data2D < ltpda_data < ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%       ts = tsdata()        - creates a blank time-series object
%       ts = tsdata(y)       - creates a time-series object with the given
%                              y-data. The data are assumed to be evenly
%                              sampled at 1Hz.
%       ts = tsdata(x,y)     - creates a time-series object with the given
%                              (x,y)-data. The sample rate is then set using
%                              the static method fitfs(). This computes the
%                              best sample rate that fits the data. If the
%                              data is evenly sampled, the sample rate is set
%                              as 1/median(diff(x)) and the x data is then
%                              not stored (empty vector).
%       ts = tsdata(y,fs)    - creates a time-series object with the given
%                              y-data. The data is assumed to be evenly sampled
%                              at the given sample rate with the first sample
%                              assigned time 0. No x vector is created.
%       ts = tsdata(y,t0)    - creates a time-series object with the given
%                              y-data. The data are assumed to be evenly
%                              sampled at 1Hz. The first sample is assumed to
%                              be at 0s offset from t0 and t0 is set to the
%                              user specified value.
%       ts = tsdata(x,y,fs)  - creates a time-series object with the given
%                              x/y data vectors. The sample rate is set to
%                              fs.
%       ts = tsdata(x,y,t0)  - creates a time-series object with the given
%                              x/y data vectors. The t0 property is set to
%                              the supplied t0 and the sample rate is
%                              computed from the x vector using the static
%                              method fitfs(). If the data is found to be
%                              evenly sampled, the x vector is discarded.
%       ts = tsdata(y,fs,t0) - creates a time-series object with the given
%                              y-data. The data are assumed to be evenly
%                              sampled at fs and the t0 property is set to
%                              the supplied t0. No x vector is generated.
%       ts = tsdata(x,y,fs,t0)-creates a time-series object with the given
%                              x-data, y-data, fs and t0.
%
% SEE ALSO: tsdata, fsdata, xydata, cdata, data2D, data3D, xyzdata
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) tsdata < data2D
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
  end
  
  %---------- Protected read-only Properties ----------
  properties (GetAccess = public, SetAccess = protected)
    t0      = time(0); % time-stamp of the first data sample in UTC format
    toffset = 0;       % time offset from t0 to the first data sample in milliseconds
    fs      = NaN;     % sample rate of data
    nsecs   = 0;       % the length of this time-series in seconds
  end
  
  %---------- Private Properties ----------
  properties (GetAccess = protected, SetAccess = protected)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.t0(obj, val)
      if (~isa(val, 'time') && ~ischar(val) && ~isnumeric(val))|| isempty(val)
        error('### The value for the property ''t0'' must be a string, a number or a time object');
      end
      if ischar(val) || isnumeric(val)
        obj.t0 = time(val);
      else
        obj.t0 = val;
      end
    end
    function set.fs(obj, val)
      if ~isnumeric(val) || isempty(val) || ~isreal(val) || val < 0
        error('### The value for the property ''fs'' must be a real positive number');
      end
      if ~utils.helper.eq2eps(obj.fs, val)
        obj.fs = val;
      end
    end
    function set.nsecs(obj, val)
      if ~isnumeric(val) || isempty(val) || ~isreal(val) || val < 0
        error('### The value for the property ''nsecs'' must be a real positive number');
      end
      obj.nsecs = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = tsdata(varargin)
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'tsdata')
            %%%%%%%%%%   data = tsdata(tsdata-object)   %%%%%%%%%%
            %----------- Copy tsdata Object   %%%%%%%%%%
            obj = copy(varargin{1}, 1);
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   data = tsdata(struct)   %%%%%%%%%%
            obj = fromStruct(obj, varargin{1});
            
          elseif isnumeric(varargin{1})
            %%%%%%%%%%   data = tsdata(y-vector)   %%%%%%%%%%
            %----------- y vector
            obj.setY(varargin{1});
            obj.setFs(1);
            
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if numel(varargin{1}) > numel(varargin{2}) && numel(varargin{2}) == 1 && ~isa(varargin{2}, 'time')
            %%%%%%%%%%   data = tsdata(y-vector, fs)   %%%%%%%%%%
            % tsdata(y,fs)
            obj.setY(varargin{1});
            obj.setFs(varargin{2});
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = tsdata(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif numel(varargin{1}) == numel(varargin{2})
            %%%%%%%%%%   data = tsdata(x-vector, y-vector)   %%%%%%%%%%
            % tsdata(x,y)
            if numel(varargin{1}) > 1
              [fs_fitfs, toff_fitfs, unevenly] = tsdata.fitfs(varargin{1});
              obj.fs = fs_fitfs;
              if unevenly
                obj.setXY(varargin{1}, varargin{2});
                toff_fitfs = 0;
              else
                obj.setY(varargin{2});
                obj.setFs(fs_fitfs);
              end
            else
              obj.setXY(varargin{1}, varargin{2});
              obj.setFs(1);
              toff_fitfs = 0;
            end
            obj.toffset = toff_fitfs*1000;
            
          elseif isa(varargin{2}, 'time')
            %%%%%%%%%%   data = tsdata(y-vector, t0)   %%%%%%%%%%
            % tsdata(y,t0)
            obj.setY(varargin{1});
            obj.setFs(1);
            obj.t0 = varargin{2};
            
          else
            error('### Unknown two argument constructor %s [%d,%d], %s [%d, %d].', class(varargin{1}), size(varargin{1}), class(varargin{2}), size(varargin{2}));
          end
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   three input   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if numel(varargin{1}) == numel(varargin{2}) && numel(varargin{3}) == 1 && ~isa(varargin{3}, 'time')
            %%%%%%%%%%   data = tsdata(x-vector, y-vector, fs)   %%%%%%%%%%
            % tsdata(x,y,fs)
            [fs_fitfs, toff_fitfs, unevenly] = tsdata.fitfs(varargin{1});
            if unevenly
              obj.setXY(varargin{1}, varargin{2});
              toff_fitfs = 0;
            else
              if abs(fs_fitfs - varargin{3}) > 2*eps(varargin{3})
                error('The requested sample rate (%g) does not match the sample rate computed from the input x values (%g)', varargin{3}, fs_fitfs);
              end
              obj.setY(varargin{2});
            end
            obj.setFs(varargin{3});
            obj.toffset = toff_fitfs * 1000;
            
          elseif numel(varargin{1}) == numel(varargin{2}) && isa(varargin{3}, 'time')
            %%%%%%%%%%   data = tsdata(x-vector, y-vector, t0)   %%%%%%%%%%
            % tsdata(x,y,t0)
            [fs_fitfs, toff_fitfs, unevenly] = tsdata.fitfs(varargin{1});
            obj.t0 = varargin{3};
            if unevenly
              obj.setXY(varargin{1}, varargin{2});
              toff_fitfs = 0;
            else
              obj.setY(varargin{2});
              obj.setFs(fs_fitfs);
            end
            obj.toffset =  toff_fitfs * 1000;
            
          elseif numel(varargin{1}) > numel(varargin{2}) && isa(varargin{3}, 'time')
            %%%%%%%%%%   data = tsdata(y-vector, fs, t0)   %%%%%%%%%%
            % tsdata(y,fs,t0)
            obj.setY(varargin{1});
            obj.setFs(varargin{2});
            obj.t0 = varargin{3};
          else
            error('### Unknown three argument constructor.');
          end
        case 4
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   four input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if numel(varargin{1}) == numel(varargin{2}) && numel(varargin{3}) == 1 && isa(varargin{4}, 'time')
            %%%%%%%%%%   data = tsdata(x-vector, y-vector, fs, t0)   %%%%%%%%%%
            [fs_fitfs, toff_fitfs, unevenly] = tsdata.fitfs(varargin{1});
            if unevenly
              obj.setXY(varargin{1}, varargin{2});
              toff_fitfs = 0;
            else
              if abs(fs_fitfs - obj.fs) > 2*eps(obj.fs)
                error('The requested sample rate (%g) does not match the sample rate computed from the input x values (%g)', obj.fs, fs_fitfs);
              end
              obj.setY(varargin{2});
            end
            obj.toffset = toff_fitfs * 1000;
            obj.setFs(varargin{3});
            obj.t0 = varargin{4};
          else
            error('### Unknown four argument constructor.');
          end
        otherwise
          error('### Unknown number of constructor arguments.');
      end
      
    end % End constructor
  end % End public methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods  (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    function ts = getTimespan(obj)
      x = obj.getX();
      if isempty(x), x = 0; end
      startTime = time(obj.t0.double+x(1));
      endTime   = time(obj.t0.double+x(end) + 1/obj.fs);
      ts = timespan(startTime, endTime);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (public, static)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true)
    
    varargout = fitfs(varargin)
    varargout = createTimeVector(varargin)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'tsdata');
    end
    
    function out = SETS()
      out = {'Default'};
    end
    
    function out = getDefaultPlist(set)
      switch lower(set)
        case 'default'
          out = plist();
        otherwise
          error('### Unknown set [%s]', set');
      end
    end
    
    function obj = initObjectWithSize(varargin)
      obj = tsdata.newarray([varargin{:}]);
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
    
    function yaxisDataDidChange(varargin)
      % Call super class
      yaxisDataDidChange@data2D(varargin{:});
      % Check number of seconds.
      obj = varargin{1};
      obj.fixNsecs();
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                               Methods (private)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, private)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
  end
  
end % End classdef

