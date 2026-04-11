% SSMPORT a helper class for the SSM class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SSMPORT a helper class for the SSM class.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%   sb = ssmport(name);
%   sb = ssmport(name, desc);
%   sb = ssmport(name, desc, units);
%
% SEE ALSO: ltpda_obj, ltpda_nuo, ssm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) ssmport < ltpda_nuo
  
  % -------- Public (read/write) Properties  -------
  properties
  end % -------- Public (read/write) Properties  -------
  
  % -------- Private read-only Properties --------
  properties (SetAccess = protected)
    name        = '.'; % name of the block
    units       = unit(); % units associated with this port
    description = ''; % description of the block
  end %% -------- Private read-only Properties --------
  
  % -------- Dependant Hidden Properties ---------
  properties (Dependent, Hidden)
  end  %-------- Dependant Hidden Properties ---------
  
  % -------- Dependant Hidden Properties Methods ------
  methods
    
  end % -------- Dependant Properties Methods ------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (public)                                  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    
    function sp = ssmport(varargin)
      switch nargin
        case 0
          % Empty constructor
        case 1
          if isa(varargin{1}, 'ssmport')
            % copy constructor.
            sp = copy(varargin{1},1);
          elseif isstruct(varargin{1})
            % sp = ssmport(struct)
            sp = fromStruct(sp, varargin{1});
          else
            error('### Unknown single argument constructor: ssmport(%s)', class(varargin{1}));
          end
        case 2
          if  isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            sp = fromDom(sp, varargin{1}, varargin{2});
          else
            error('### Unknown two argument constructor: ssmport(%s, %s)', class(varargin{1}), class(varargin{2}));
          end
        otherwise
          error('### Unknown argument constructor');
      end
    end % End constructor
    
  end %% -------- constructor ------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (hidden)                                  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Hidden = true)
    
    
    function clearAllUnits(inputs)
      for kk=1:numel(inputs)
        inputs(kk).units = [];
      end
    end
    
    % properties methods
    function portNames = portNames(port)
      portNames = cell(1, numel(port));
      for i=1:numel(port)
        portNames{i} = port(i).name;
      end
    end
    
    function portDescriptions = portDescriptions(port)
      portDescriptions = cell(1, numel(port));
      for i=1:numel(port)
        portDescriptions{i} = port(i).description;
      end
    end
    
    function portUnits = portUnits(port)
      portUnits = unit.initObjectWithSize(1, numel(port));
      for i=1:numel(port)
        portUnits(i) = port(i).units;
      end
    end
    
    
    % setter methods
    function port = setName(port, names, blockName)
      % checking block name is acceptable
      blockName = upper(blockName);
      if numel(strfind(blockName,'.'))>0
        error('The "." is not allowed in ssmblock name')
      end
      if numel(strfind(blockName,' '))>0
        error('The space " " is not allowed in ssmblock name')
      end
      % setting portNames depending on wether they are provided or not
      if isempty(names) % setting for empty port names
        for ii=1:numel(port)
          port(ii).name = [blockName '.variable_' num2str(ii)];
        end
      else % setting for char/cellstr port names
        if ischar(names), names = {names};  end
        for ii=1:numel(port)
          portName = names{ii};
          if numel(strfind(portName,'.'))>0
            error('The "." is not allowed in ssmport name')
          end
          if numel(strfind(portName,' '))>0
            error('The space " " is not allowed in ssmport name')
          end
          port(ii).name = [blockName '.' lower(portName)];
        end
      end
    end
    
    function port = modifyBlockName(port, oldName, newName)
      if numel(strfind(newName,'.'))>0
        error('The "." is not allowed in ssmblock name')
      end
      if numel(strfind(newName,' '))>0
        error('The space " " is not allowed in ssmblock name')
      end
      newName = upper(newName);
      for ii=1:numel(port)
        if ~isempty(port(ii).name)
          str = port(ii).name;
          [blockName, portName] = ssmblock.splitName(str);
          port(ii).name = [newName '.' portName];
        end
      end
    end
    
    function port = setDescription(port, descriptions)
      if ischar(descriptions), descriptions = {descriptions};  end
      if numel(descriptions)==1
        for ii=1:numel(port)
          port(ii).description = descriptions{1};
        end
      else
        for ii=1:numel(port)
          port(ii).description = descriptions{ii};
        end
      end
    end
    
    function port = setUnits(port, units)
      if ~isa(units, 'unit')
        error('the port unit field must be of class unit')
      end
      if numel(units)==1
        for ii=1:numel(port)
          port(ii).units = units(1);
        end
      else
        for ii=1:numel(port)
          port(ii).units = units(ii);
        end
      end
    end
    
  end   %% -------- Hidden methods ------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, private)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Static=true, Access=private)
  end   %% -------- private static methods ------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static)                                  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Static=true)
    
    function obj = initObjectWithSize(varargin)
      obj = ssmport.newarray([varargin{:}]);
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'ssmport');
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
    
  end %% -------- public static methods ------
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private)                                 %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods(Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (protected)                               %
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
  
end
