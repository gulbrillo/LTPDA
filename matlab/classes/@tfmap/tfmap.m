% TFMAP time-frequency data object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TFMAP time-frequency data object class constructor.
%
% SUPER CLASSES: xyzdata < data3D < data2D < ltpda_data < ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%       tf = tfmap()      - creates an empty tfmap object
%       tf = tfmap(z)     - creates a tfmap object with the given
%                              z-data.
%       tf = tfmap(x,y,z)  - creates a tfmap object with the given
%                              (x,y,z)-data.
%
% SEE ALSO: tsdata, fsdata, xydata, cdata, data2D, data3D, xyzdata
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) tfmap < data3D & tsdata
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
  end
  
  %---------- Protected read-only Properties ----------
  properties (GetAccess = public, SetAccess = protected)
  end
  
  %---------- Private Properties ----------
  properties (GetAccess = protected, SetAccess = protected)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = tfmap(varargin)
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'tfmap')
            %%%%%%%%%%   xy = tfmap(tfmap)   %%%%%%%%%%
            obj = copy(varargin{1}, 1);
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   data = tfmap(struct)   %%%%%%%%%%
            obj = fromStruct(obj, varargin{1});
            
          elseif isnumeric(varargin{1}) && length(varargin{1}) > 1
            %%%%%%%%%%   xyz = tfmap(z_vector)   %%%%%%%%%%
            obj.setX(1:size(varargin{1}, 1));
            obj.setY(1:size(varargin{1}, 2));
            obj.setZ(varargin{1});
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%  ts = tfmap(plist)   %%%%%%%%%%
            if nparams(varargin{1}) == 0
              % return empty object
            else
              error('### Unknown tfmap constructor method.');
            end
            
          else
            error('### Unknown tfmap constructor method with one argument.');
          end
          
        case 2
          
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if  isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = tfmap(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          else
            error('### Unknown constructor method for two inputs.');
          end
          
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   three input   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          obj.setX(varargin{1});
          obj.setY(varargin{2});
          obj.setZ(varargin{3});
        otherwise
          error('### Unknown number of constructor arguments.');
      end
      
      %%%%%%%%%%   Normalize the the x- and y-vector   %%%%%%%%%%
      
      nx = size(obj.zaxis.data, 2);
      ny = size(obj.zaxis.data, 1);
      
      if length(obj.xaxis.data) ~= nx
        error('### X-vector has wrong length.');
      end
      if length(obj.yaxis.data) ~= ny
        error('### Y-vector has wrong length.');
      end
      
    end % End constructor
  end % End public methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end 
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
    
    function yaxisDataDidChange(varargin)
      % Call super class
      % It is necessary to define this function in this class because it
      % inherit the function from both super classes.
      yaxisDataDidChange@data3D(varargin{:});
    end
    
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
      ii = utils.helper.generic_getInfo(varargin{:}, 'tfmap');
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
      obj = tfmap.newarray([varargin{:}]);
    end
    
  end % End static methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, private)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static, Access = private)
  end % End static, private methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin);
  end
    
  
end % End classdef
