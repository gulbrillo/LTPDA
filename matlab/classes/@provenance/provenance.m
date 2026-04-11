% PROVENANCE constructors for provenance class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  PROVENANCE constructors for provenance class.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%       p = provenance();          - creates an empty provenance object
%       p = provenance('creator'); - creates a provenance object with defined user
%
% SEE ALSO:     ltpda_obj, ltpda_nuo
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) provenance < ltpda_nuo
  
  %------------------------------------------------
  %---------- Private read-only Properties --------
  %------------------------------------------------
  properties (SetAccess = private)
    creator               = char(java.lang.System.getProperties.getProperty('user.name')); % current user of the LTPDA toolbox
    ip                    = '';
    hostname              = '';
    os                    = computer; % used system of the creator
    matlab_version        = getappdata(0, 'matlab_version'); % MATLAB version
    sigproc_version       = getappdata(0, 'sigproc_version'); % Signal Processing Toolbox version
    symbolic_math_version = getappdata(0, 'symbolic_math_version'); % Symbolic Math Toolbox version
    optimization_version  = getappdata(0, 'optimization_version'); % Optimization Toolbox version
    database_version      = getappdata(0, 'database_version'); % Database Toolbox version
    control_version       = getappdata(0, 'control_version'); % Control System Toolbox version
    ltpda_version         = getappdata(0, 'ltpda_version'); % LTPDA toolbox version
  end
  
  properties (SetAccess = protected)
  end
  
  %------------------------------------------------
  %-------- Declaration of public methods --------
  %------------------------------------------------
  methods
    
    %------------------------------------------------
    %-------- Property rules                 --------
    %------------------------------------------------
    
    %----------------------------
    % Constructor
    %----------------------------
    function obj = provenance(varargin)
      
      persistent cached_ip
      persistent cached_hostname
      
      if isempty(cached_ip) || isempty(cached_hostname)        
        try
          cached_ip       = char(getHostAddress(java.net.InetAddress.getLocalHost)); % ip address of the creator
          cached_hostname = char(getHostName(java.net.InetAddress.getLocalHost)); % hostname of the creator
        catch
          cached_ip       = 'unavailable';
          cached_hostname = 'unavailable';
        end
      end
      
      obj.ip       = cached_ip;
      obj.hostname = cached_hostname;
      
      switch nargin
                
        case 0
        case 1
          if isstruct(varargin{1})
            %%%%%%%%%%   prov = provenance(structure)   %%%%%%%%%%
            obj = fromStruct(obj, varargin{1});
            
          elseif ischar(varargin{1})
            obj.creator = varargin{1};
            
          elseif isa(varargin{1}, 'provenance')
            obj = copy(varargin{1}, 1);
          else
            error('### Unknown constructor');
          end
          
        case 2
          if  isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = provenance(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
          else
            error('### Unknown constructor method for two inputs.');
          end
      end
      
    end % End of constructor
    
  end % End public methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                               Methods (public)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = copy(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end 
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (private)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Public)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'provenance');
    end
    
    function out = SETS()
      out = {'Default'};
    end
    
    function out = getDefaultPlist(set)
      switch lower(set)
        case 'default'
          out = plist();
        otherwise
          error('### Unknown set [%s]', set);
      end
    end
    
    function obj = initObjectWithSize(varargin)
      obj = provenance.newarray([varargin{:}]);
    end
    
  end % End static methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Private)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Access = private)
  end % End static private methods

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  methods (Static = true, Hidden = true)
    varargout = setFromEncodedInfo(varargin)
  end
  
end % End classdef

