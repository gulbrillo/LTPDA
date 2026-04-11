% FSDATA frequency-series object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FSDATA frequency-series object class constructor.
%              Create a frequency-series data object.
%
% SUPER CLASSES: data2D < ltpda_data < ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%       fsd = fsdata()        - creates a blank frequency-series object
%       fsd = fsdata(y)       - creates a frequency-series object with the given
%                               y-data. Sample rate of the data is assumed to
%                               be 1Hz.
%       fsd = fsdata(f,y)     - creates a frequency-series object with the given
%                               (x,y)-data. The sample rate is then set as
%                               2*x(end).
%       fsd = fsdata(y,fs)    - creates a frequency-series object with the given
%                               y-data and sample rate. The frequency
%                               vector is grown assuming the first y
%                               sample corresponds to 0Hz and the last
%                               sample corresponds to the Nyquist
%                               frequency.
%       fsd = fsdata(x,y,fs) - creates a frequency-series object with the given
%                               x,y-data and sample rate.
%
% SEE ALSO: tsdata, fsdata, xydata, cdata, data2D, data3D, xyzdata
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) fsdata < data2D
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
  end
  
  %---------- Protected read-only Properties ----------
  properties (GetAccess = public, SetAccess = protected)
    t0      = time(0); % time-stamp of the first data sample
    navs    = NaN; % number of averages
    fs      = NaN; % sample rate of data
    enbw    = NaN; % equivalent noise bandwidth
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
    function set.navs(obj, val)
      if ~isnumeric(val) || isempty(val) || length(val) > 1 || (~isnan(val) && rem(val,1)~=0)
        error('### The value for the property ''navs'' must be a positive integer');
      end
      obj.navs = val;
    end
    function set.fs(obj, val)
      if ~isempty(val)
        if ~isnumeric(val)  || ~isreal(val) || val < 0
          error('### The value for the property ''fs'' must be a real positive number');
        end
      end
      obj.fs = val;
    end
    function set.enbw(obj, val)
      if ~isnumeric(val) || ~isreal(val) || any(val < 0)
        error('### The value for the property ''enbw'' must be a real positive number or a vector');
      end
      if ~isempty(val) && ~isempty(obj.getY)
        if length(val) ~=1 && (length(val) ~= length(obj.getY))
          error('### The ENBW can only be a single number, of a vector the same length as the y data.');
        end
      end
      if size(val, 1) == 1
        obj.enbw = val.';
      else
        obj.enbw = val;
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = fsdata(varargin)
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'fsdata')
            %%%%%%%%%%   data = fsdata(fsdata-object)   %%%%%%%%%%
            %----------- Copy fsdata Object
            obj = copy(varargin{1}, 1);
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   data = fsdata(struct)   %%%%%%%%%%
            obj = fromStruct(obj, varargin{1});
            
          elseif isnumeric(varargin{1})
            %%%%%%%%%%   data = fsdata(y-vector)   %%%%%%%%%%
            %----------- y vector
            obj.setY(varargin{1});
            obj.setFs(1);
            obj.setX(fsdata.getFfromYFs(length(obj.y), obj.fs));
            
          else
            error('### Unknown single argument constructor.');
          end
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = fsdata(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif numel(varargin{1}) > numel(varargin{2}) && numel(varargin{2}) == 1
            %%%%%%%%%%   data = fsdata(y-vector, fs)   %%%%%%%%%%
            % fsdata(y,fs)
            obj.setY(varargin{1});
            obj.setFs(varargin{2});
            obj.setX(fsdata.getFfromYFs(length(obj.y), obj.fs));
            
          elseif numel(varargin{1}) == numel(varargin{2})
            %%%%%%%%%%   data = fsdata(x-vector, y-vector)   %%%%%%%%%%
            % fsdata(x,y)
            obj.setXY(varargin{1}, varargin{2});
            
          else
            error('### Unknown two argument constructor.');
          end
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   three input   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if numel(varargin{1}) == numel(varargin{2}) && numel(varargin{3}) == 1
            %%%%%%%%%%   data = fsdata(x-vector, y-vector, fs)   %%%%%%%%%%
            % fsdata(x,y,fs)
            obj.setXY(varargin{1}, varargin{2});
            obj.setFs(varargin{3});
            
          else
            error('### Unknown three argument constructor.');
          end
        otherwise
          error('### Unknown number of constructor arguments.');
      end
    end % End constructor
  end % End public methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods  (Public, hidden)                    %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden = true)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                               Methods (private)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Methods (static)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Static)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'fsdata');
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
      obj = fsdata.newarray([varargin{:}]);
    end
    
  end % End static methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, private)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static, Access = private)
    f = getFfromYFs(N,fs)
  end % End static, private methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
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
  
end % End classdef
