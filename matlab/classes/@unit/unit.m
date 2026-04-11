% UNIT a helper class for implementing units in LTPDA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% UNIT a helper class for implementing units in LTPDA.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%   u = unit(str);
%
% EXAMPLES:
%
%       u = unit('m');            - Create a simple unit
%       u = unit('m^3');          - With an exponent
%       u = unit('m^1/2');
%       u = unit('m^1.5');
%       u = unit('pm^2');         - With a prefix
%       u = unit('m s^-2 kg');    - Multiple units
%       u = unit('m/s');          - Units with division
%       u = unit('m^.5 / s^2');
%
% SUPPORTED PREFIXES:      unit.supportedPrefixes
% SUPPORTED UNITS:         unit.supportedUnits
%
% SEE ALSO: ltpda_obj, ltpda_nuo
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%classdef unit

classdef (Hidden = true) unit < ltpda_nuo
  
  %----------------------------------------
  %- Private properties
  %----------------------------------------
  properties (SetAccess = protected)
    strs    = {}; % unit sign
    exps    = []; % exponent of the units
    vals    = int8([]); % prefixes of the units (all SI prefixes are supported)
  end
  
  %----------------------------------------
  %- Public methods
  %----------------------------------------
  methods
    %----------------------------------------
    %- Setter for prefixes
    %----------------------------------------
    
    function u = set.vals(u, v)
      switch class(v)
        case 'int8'
          u.vals = int8(v);
        case 'double'
          u.vals = int8(round(log10(v)));
      end
    end

    %----------------------------------------
    %- Constructor
    %----------------------------------------
    function u = unit(varargin)
      
      switch nargin
        case 0
          % Empty constructor
        case 1
          if ischar(varargin{1})
            % String input
            ustr = strtrim(varargin{1});
            if ~isempty(ustr)
              
              % Handle the output of char(unit)
              ustr = strtrim(strrep(strrep(ustr, '[', ' '), ']', ' '));
              
              % split on whitespace
              expr_unit = '([1a-zA-Z]+)';
              expr_frac = '([+-]?[0-9]*(\.[0-9]+)?(/-?[0-9]+)?)';
              expr = [' *' expr_unit '(\^(\(' expr_frac '\)|' expr_frac '))* *'];
              tks = strtrim(regexp(ustr, expr, 'match'));
              ops = strtrim(regexp(ustr, expr, 'split'));
              
              % combine each unit
              for jj = 1:numel(tks)
                % Parse string
                if tks{jj} == '1' % Special case for '1/s'
                  u2.strs = '';
                  u2.exps = [];
                  u2.vals = int8([]);
                else
                  % try to parse this unit string. If it fails, we leave
                  % the units empty and give a warning.
                  try
                    [us, exp, val] = unit.parse(tks{jj});
                    u2.strs = {us};
                    u2.exps = exp;
                    u2.vals = val;
                  catch Me
                    warning('Failed to parse unit [%s]: leaving empty. [%s]', tks{jj}, Me.message);
                    u2.strs = '';
                    u2.exps = [];
                    u2.vals = int8([]);
                  end
                end
                
                switch ops{jj}
                  case ''
                    u.strs = [u.strs u2.strs];
                    u.exps = [u.exps u2.exps];
                    u.vals = [u.vals u2.vals];
                  case '+'
                    u2 = unit(u2);
                    u = u + u2;
                  case '-'
                    u2 = unit(u2);
                    u = u - u2;
                  case {'*', '.*'}
                    u2 = unit(u2);
                    u = u * u2;
                  case {'/', './'}
                    u2 = unit(u2);
                    u = u / u2;
                  otherwise
                    error('### Unknown operator [%s]', ops{jj});
                end
              end
            end
            
          elseif isstruct(varargin{1})
            u = fromStruct(u, varargin{1});
            
          elseif isa(varargin{1}, 'double')
            
            if isempty(varargin{1})
            else
              s = unit.supportedUnits;
              if numel(varargin{1}) == numel(s)
                positions = not(varargin{1}==0);
                u.strs = s(positions);
                u.exps = varargin{1}(positions);
                u.vals = int8(zeros(1, sum(positions)));
              else
                error('variable unit.supportedUnits does not match');
              end
            end
            
          elseif isa(varargin{1}, 'unit')
            u = varargin{1};
            
          elseif iscell(varargin{1})
            
            for kk = 1:numel(varargin{1})
              u(kk) = unit(varargin{1}{kk});
            end
            
          else
            error('### Unknown single argument constructor. The constructor doesn''t support the class [%s]', class(varargin{1}));
          end
          
        case 2
          if  isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            u = fromDom(u, varargin{1}, varargin{2});

          elseif (isa(varargin{1}, 'unit') || ischar(varargin{1})) && ...
                 (isa(varargin{2}, 'unit') || ischar(varargin{2}))
            u = varargin{1};
            u = [u unit(varargin{2})];
            
          else
            error('### Unknown constructor method for two inputs.');
          end
          
        otherwise
          u = [];
          for ii = 1:numel(varargin)
            u = [u unit(varargin{ii})];
          end
      end
      
    end % End constructor
    
  end % End public methods
  
  %----------------------------------------
  %- Private Static methods
  %----------------------------------------
  methods (Static=true, Access=private)
    
    %----------------------------------------
    %- Parse a unit definition string
    %----------------------------------------
    function [us, exponent, val] = parse(ustr)
      
      % start with the most common case of a single character
      if length(ustr) < 2
        sm  = ustr;
        exponent = 1;
        val = int8(0);
      else
        % parse string
        [s, t] = strtok(ustr, '^');
        if ~isempty(t)
          % drop any ()
          t = strrep(t(2:end), '(','');
          t = strrep(t, ')', '');
          exponent = eval(t);
        else
          exponent = 1;
        end
        
        if length(s) > 1 && utils.helper.ismember(s(1), unit.supportedPrefixes) && utils.helper.ismember(s(2:end), unit.supportedUnits)
          % check for prefix
          val = unit.prefix2val(s(1));
          sm  = s(2:end);
        elseif length(s) > 2 && utils.helper.ismember(s(1:2), unit.supportedPrefixes) && utils.helper.ismember(s(3:end), unit.supportedUnits)
          % special case for the prefix 'da'
          val = unit.prefix2val(s(1:2));
          sm  = s(3:end);
        else
          val = int8(0);
          sm  = s;
        end
      end
      
      % Check unit
      if ~isempty(sm) && ~utils.helper.ismember(sm, unit.supportedUnits)
        error(['### Unsupported unit: [' sm ']']);
      end
      
      % set unit string
      us  = sm;
      
    end % End parse
    
    
    
    %----------------------------------------
    %- Get the value associated with a prefix
    %----------------------------------------
    function val = prefix2val(p)
      [pfxs, pfxvals] = unit.supportedPrefixes;
      val = pfxvals(strcmp(p, pfxs));
    end
    
    %----------------------------------------
    %- Get the prefix associated with a value
    %----------------------------------------
    function p = val2prefix(val)
      persistent pfxs
      persistent pfxvals
      if isempty(pfxs)
        [pfxs, pfxvals] = unit.supportedPrefixes;
      end
      res = val==pfxvals;
      if any(res)
        p = pfxs{val==pfxvals};
      else
        p = '';
      end
    end
  end % End static private methods
  
  %----------------------------------------
  %- Public static methods
  %----------------------------------------
  methods (Static=true)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'unit');
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
      obj = unit.newarray([varargin{:}]);
    end
    
    %----------------------------------------
    %- Return a list of supported prefixes
    %----------------------------------------
    function varargout = supportedPrefixes
      
      persistent pfxs
      persistent pfxvals
      
      if isempty(pfxs)
        pfxs = {...
          'y',  'z', 'a', 'f', 'p', 'n', 'u', 'm', 'c', 'd', '', ...
          'da', 'h', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'};
        pfxvals = int8([-24:3:-3 -2:1:2 3:3:24]);
        
      end
      
      if nargout == 1
        varargout{1} = pfxs;
      elseif nargout == 2
        varargout{1} = pfxs;
        varargout{2} = pfxvals;
      else
        for kk = 1:numel(pfxs)
          fprintf('%-3s[1e%g]\n', pfxs{kk}, pfxvals(kk));
        end
      end
      
    end
    
    %----------------------------------------
    %- Return a list of supported units
    %----------------------------------------
    function bu = supportedUnits
      
      persistent outUnits
      
      if isempty(outUnits)
        outUnits = {'', 'm', 'kg', 's', 'A', 'K', 'mol', 'cd', ...
          'rad', 'deg', 'sr', 'Hz', 'N', 'Pa', 'J', 'W', 'C', 'V', 'F', ...
          'Ohm', 'S', 'Wb', 'T', 'H', 'degC', ...
          'Bq', 'eV', 'e', 'amu', ...
          'bar', 'l', 'L', ...
          'ly', 'au', 'AU', 'pc', ...
          'sccm', ...
          'min', 'h', 'd', 'D', ...
          'Count', 'arb', 'Index',...
          'cycles'};
        
        prefs = getappdata(0, 'LTPDApreferences');
        if ~isempty(prefs)
          userUnits = prefs.getMiscPrefs.getUnits;
          for kk = 0:userUnits.size-1
            outUnits{end + 1} = char(userUnits.get(kk));
          end
        end
      end
      
      bu = outUnits;
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
    
  end
  
  % factory constructors
  methods (Static = true)
    
    function uout = seconds
      persistent u;
      if isempty(u)
        u = unit('s');
      end
      uout = u;
    end
    
    function uout = Hz
      persistent u;
      if isempty(u)
        u = unit('Hz');
      end
      uout = u;
    end
    
  end
  
  %----------------------------------------
  %- Private methods
  %----------------------------------------
  
  methods (Access = private)
  end
  
  %----------------------------------------
  %- Protected methods
  %----------------------------------------
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
  end
  
  methods (Hidden = true)
    varargout = toSI(varargin)
  end
  
end
