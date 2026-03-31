% DATA3D is the abstract base class for 3-dimensional data objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DATA3D is the base class for 3-dimensional data objects. This is
%              an abstract class.
%
% SUPER CLASSES: ltpda_data < ltpda_nuo < ltpda_obj
%
% SEE ALSO: ltpda_data, fsdata, tsdata, xydata, data3D
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) data3D < data2D
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties (GetAccess = public, SetAccess = public)
    zaxis = []; % an ltpda_vector object
  end
  
  %---------- Protected read-only Properties ----------
  properties (GetAccess = public, SetAccess = protected)
  end
  
  %---------- Private Properties ----------
  properties (GetAccess = public, SetAccess = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    %--- zaxis
    function set.zaxis(obj, val)
      if ~isempty(val) && ~isa(val, 'ltpda_vector')
        error('### The value for the property ''zaxis'' must be an ltpda_vector object');
      end
      obj.zaxis = val;
    end
  end
  
  % -------- Getter Methods ------
  methods
    function value = z(obj, varargin)
      % Returns the z values of the data object.
      switch nargin
        case 1
          value = obj.zaxis.data;
        case 2
          value = obj.zaxis.data(varargin{1});
        otherwise
          error('Incorrect inputs');
      end
    end
    
    function value = dz(obj, varargin)
      % Returns the dz values of the data object.
      switch nargin
        case 1
          value = obj.zaxis.ddata;
        case 2
          value = obj.zaxis.ddata(varargin{1});
        otherwise
          error('Incorrect inputs');
      end
    end
    
    function value = zunits(obj)
      % Returns the zunits of the data object.
      value = obj.zaxis.units;
    end
    
    function value = zaxisname(obj)
      % Returns the name of the z-axis.
      value = obj.zaxis.name;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = data3D(varargin)
      createZaxis(obj);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
  end
  
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
    function createZaxis(obj)
      obj.zaxis = ltpda_vector();
      obj.zaxis.setName('z');
      obj.zaxis.setUnits(unit());
    end
    function xaxisDataDidChange(varargin)
      %       disp('data3D: xaxisDataDidChange')
    end
    function yaxisDataDidChange(varargin)
      %       disp('data3D: yaxisDataDidChange');
    end
    function zaxisDataDidChange(varargin)
      %       disp('data3D: zaxisDataDidChange')
    end
    function xaxisDataWillChange(varargin)
      %       disp('data3D: xaxisDataWillChange')
    end
    function yaxisDataWillChange(varargin)
      %       disp('data3D: yaxisDataWillChange');
    end
    function zaxisDataWillChange(varargin)
      %       disp('data3D: zaxisDataWillChange')
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (private)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (static)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'data3D');
    end
    
    function out = SETS()
      out = {};
    end
    
    function out = getDefaultPlist()
      out = [];
    end
    
  end
  
end

