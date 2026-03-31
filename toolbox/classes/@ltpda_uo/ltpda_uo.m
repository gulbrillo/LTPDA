% LTPDA_UO is the abstract ltpda base class for ltpda user object classes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LTPDA_UO is the ltpda base class for ltpda user object classes.
%              This class is an abstract class and it is not possible to create
%              an instance of this class.
%              ALL ltpda user object classes inherit this 'abstract' class.
%
% SUPER CLASSES: ltpda_obj
%
% SUB CLASSES:   ltpda_uoh, plist
%
% LTPDA_UO PROPERTIES:
%
%     Protected Properties (read only)
%       UUID          - Universally Unique Identifier of 128-bit
%       description   - description of the object
%       name          - name of the object
%
% SEE ALSO: ltpda_obj, ltpda_uoh, plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) ltpda_uo < ltpda_obj
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    name        = ''; % name of the object
    description = ''; % description of the object
    UUID        = ''; % Universally Unique Identifier of 128-bit
  end
  
  properties (SetAccess = protected, Hidden = true)
    mdlfile     = ''; % Not used
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.description(obj, val)
      if ~ischar(val)
        error('### The value for the property ''description'' should be a string.');
      end
      obj.description = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = ltpda_uo(varargin)
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = bsubmit(varargin);
    varargout = save(varargin)
    varargout = submit(varargin);
    varargout = update(varargin);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
    varargout = setUUID(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (public, static)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true)
    
    varargout = getBuiltInModels(varargin)
    varargout = retrieve(varargin)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'ltpda_uo');
    end
    
    function out = SETS()
      out = {'Default',    ...
        'From MAT File',   ...
        'From XML File',   ...
        'From Repository', ...
        'From Built-in Model'};
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
    varargout = load(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromFile(varargin)
    varargout = fromDataInMAT(varargin)
    varargout = fromDatafile(varargin)
    varargout = fromLISO(varargin)
    varargout = fromComplexDatafile(varargin)
    varargout = fromRepository(varargin)
    varargout = fromModel(varargin)
    varargout = fromStruct(varargin)
    varargout = legendString(varargin)
    varargout = processSetterValues(varargin)
    varargout = prepareSinfoForSubmit(varargin)
    varargout = setPropertyValue(varargin)
    varargout = setPropertyValue_core(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(out, set)
      switch lower(set)
        case 'default'
        case 'from repository'
          out = out.append(plist.FROM_REPOSITORY_PLIST);
        case 'from xml file'
          out = out.append(plist.FROM_XML_FILE);
        case 'from mat file'
          out = out.append(plist.FROM_MAT_FILE);
        case 'from built-in model'
          out = out.append(plist.FROM_BUILT_IN);
      end
    end
    
    function str = createErrorStr(varargin)
      strArgs = cellfun(@(s) sprintf('''%s'' [%dx%d]', class(s), size(s)), varargin, 'uniformOutput', false);
      strArgs = utils.prog.strjoin(strArgs);
      if nargin == 1
        str = sprintf('\n<strong>Unknown %d argument constructor.</strong>\nThe argument is: %s', length(varargin), strtrim(strArgs));
      else
        str = sprintf('\n<strong>Unknown %d argument constructor.</strong>\nThe arguments are: %s', length(varargin), strtrim(strArgs));
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
    sinfo = submitDialog(sinfo, pl)
    pl    = convertSinfo2Plist(pl, sinfo)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (abstract)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Abstract)
    varargout = string(varargin)
  end
  
  methods (Access = public, Static = true)
    function obj = initObjectWithSize(varargin)
      obj = ltpda_uo.newarray([varargin{:}]);
    end
  end
  
end

