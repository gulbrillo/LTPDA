% PZ is the ltpda class that provides a common definition of poles and zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PZ is the ltpda class that provides a common definition of
%              poles and zeros.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
% CONSTRUCTORS:
%
%          p = pz(f)        % specify frequency
%          p = pz(f,q)      % specify frequency and Q
%          p = pz(c)        % create with complex representation
%          p = pz({[f,q]})
%          p = pz({[f1,q1], f2, [f3, q3]})   -> creates three objects
%
% SEE ALSO: ltpda_obj, ltpda_nuo, pzmodel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) pz < ltpda_nuo
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Public (read/write) Properties  ----------
  properties
  end
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    f       = NaN; % frequency of pole/zero
    q       = NaN; % quality factor of pole/zero
    ri      = NaN; % complex representation of pole/zero
  end
  
  %---------- Private Properties ----------
  properties (GetAccess = protected, SetAccess = protected)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.f(obj, val)
      if ~isnumeric(val) || isempty(val) || ~isreal(val)
        error('### The value for the property ''f'' must be a real positive number');
      end
      obj.f = val;
    end
    function set.q(obj, val)
      if ~isnumeric(val) || isempty(val) || ~isreal(val)
        error('### The value for the property ''q'' must be a real positive number');
      end
      obj.q = val;
    end
    function set.ri(obj, val)
      if ~isnumeric(val) || isempty(val)
        error('### The value for the property ''ri'' must be a number');
      end
      % Have 'ri' always as a column vector
      if size(val,2) ~= 1
        val = val.';
      end
      obj.ri = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = pz(varargin)
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'pz')
            %%%%%%%%%%   Copy ltpda_obj Object           %%%%%%%%%%
            %%%%%%%%%%   p1 = pz(pz-object)   %%%%%%%%%%
            obj = copy(varargin{1}, 1);
            
          elseif isnumeric(varargin{1})
            %%%%%%%%%%   real or complex pole/zero   %%%%%%%%%%
            if isempty(varargin{1})
              % do nothing
            elseif length(varargin{1}) == 1
              if isreal(varargin{1})
                %%%%%%%%%%   p1 = pz(3)   %%%%%%%%%%
                obj.setF(varargin{1});
                obj.setQ(NaN);
              else
                %%%%%%%%%%   p1 = pz(1+3i)   %%%%%%%%%%
                obj.setRI(varargin{1});
                if (obj.q - 0.5) < 1e-10
                  % if complex vale is Q = 0.5 return two equal real poles
                  disp('!!! Q = 0.5! Returning two equal real poles/zeros;')
                  obj.setQ(NaN);
                  obj = [obj obj];
                end
              end
            elseif length(varargin{1}) == 2
              %%%%%%%%%%   p1 = pz([1 2])   %%%%%%%%%%
              Q = varargin{1}(2);
              if (Q>0.5)
                obj.setF(varargin{1}(1));
                obj.setQ(varargin{1}(2));
              elseif (Q<=0.5 && Q>=0)
                % interpret as 2 real poles
                ffs = pz.fq2ri(varargin{1}(1), varargin{1}(2));
                obj = [pz(ffs(1)/2/pi) pz(ffs(2)/2/pi)];
              else
                error('### Q must be a positive value');
              end
              
            else
              error('### Unknown constructor for the input %s', mat2str(varargin{1}));
            end
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%   p1 = pz(plist-object)   %%%%%%%%%%
            pl = varargin{1};
            pl_f  = find_core(pl, 'f');
            pl_q  = find_core(pl, 'q');
            pl_ri = find_core(pl, 'ri');
            if ~isempty(pl_f)
              obj.setF(pl_f);
              if ~isempty(pl_q)
                obj.setQ(pl_q);
              end
            elseif ~isempty(pl_ri)
              obj.setRI(pl_ri);
            else
              error('### Unknown plist constructor');
            end
            
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   p1 = pz(structure)   %%%%%%%%%%
            obj = fromStruct(obj, varargin{1});
            
          elseif iscell(varargin{1})
            %%%%%%%%%%   p1 = pz({[1 2], 1+2i, 3})   %%%%%%%%%%
            if isempty(varargin{1})
              return
            end
            
            obj = pz.initObjectWithSize(size(varargin{1}));
            for kk = 1:numel(varargin{1})
              obj = [obj pz(varargin{1}{kk})];
            end
            
          elseif isobject(varargin{1})
            %%%%%%%%%%   p1 = pz(ao)   %%%%%%%%%%
            obj = feval('pz', double(varargin{1}));
            
          elseif ischar(varargin{1})
            %%%%%%%%%%   p1 = pz('{[1 2], 1+2i, 3}')   %%%%%%%%%%
            obj = feval('pz', eval(varargin{1}));
            
          else
            error('### Unknown call of the pz constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if  isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = pz(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          else
            %%%%%%%%%%   obj = pz(f, q)   %%%%%%%%%%
            % f,q constructor
            obj.setF(varargin{1});
            obj.setQ(varargin{2});
          end
        otherwise
          error('### Unknown number of arguments.');
      end
      
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    varargout = cp2iir(varargin)
    varargout = cz2iir(varargin)
    varargout = rz2iir(varargin)
    varargout = rp2iir(varargin)
    varargout = copy(varargin)
    varargout = string(varargin)
    [f,r]     = resp(varargin)  
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    ii = setF(ii, val)
    ii = setQ(ii, val)
    ii = setRI(ii, val)
    
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
  %                              Methods (static, protected)                  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static)
    [f0, q] = ri2fq(c);
    ri      = fq2ri(f0, Q);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Private)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Access = private)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (static)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'pz');
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
      obj = pz.newarray([varargin{:}]);
    end
    
    r = resp_pz_Q_core(f, f0, Q)
    r = resp_pz_noQ_core(f, f0)
    r = resp_add_delay_core(r, f, delay)    
 
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin);
  end
  
end % End classdef
