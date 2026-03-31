% MIIR IIR filter object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MIIR IIR filter object class constructor.
%              Create a miir object.
%
%
% CONSTRUCTORS:
%
%       f = miir()              - creates an empty miir object.
%       f = miir(fi)            - creates a copy of the input miir object, fi.
%       f = miir(pzm)           - creates a miir object from a pole/zero model
%       f = miir(pf)            - creates a vector of miir objects from a parfrac model
%       f = miir(a,b,fs)        - creates a miir object from the coefficient
%                                 vectors 'a' and 'b' **.
%                                 The sample rate for which the filter is
%                                 designed should be specified as well.
%       f = miir('foo_iir.fil') - create a miir object from a
%                                 LISO IIR .fil file.
%       f = miir('foo_iir.xml') - create a miir object loading the miir object
%                                 from disk.
%       f = miir('foo_iir.mat') - create a miir object loading the miir object
%                                 from disk.
%       f = miir(pl)            - create a miir object from the description
%                                 given in the parameter list.
%
%
% EXAMPLE 1:   Create an order 1 highpass filter with high frequency gain 2.
%              Filter is designed for 10 Hz sampled data and has a cut-off
%              frequency of 0.2 Hz.
%
%              >> pl = plist('type', 'highpass', ...
%                            'order', 1,         ...
%                            'gain',  2.0,       ...
%                            'fs',    10,        ...
%                            'fc',    0.2);
%              >> f = miir(pl)
%
% NOTES:    ** The convention used here for naming the filter coefficients is
%              the opposite to MATLAB's convention. The recursion formula
%              for this convention is
%
%              b(1)*y(n) = a(1)*x(n) + a(2)*x(n-1) + ... + a(na+1)*x(n-na)
%                           - b(2)*y(n-1) - ... - b(nb+1)*y(n-nb)
%
% <a href="matlab:utils.helper.displayMethodInfo('miir', 'miir')">Parameters Description</a>
%
%
% SEE ALSO:    mfir, ltpda_filter, ltpda_uoh, ltpda_uo, ltpda_obj, plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef miir < ltpda_filter
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    b       = []; % set of denominator coefficients
    histin  = []; % input history values to filter
  end
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected, Dependent = true)
    ntaps % number of coefficients in the filter
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.histin(obj, val)
      if ~isempty(val)
        if ~isnumeric(val) || ~isreal(val)
          error('### The value for the property ''histin'' must be a real number(s)');
        end
      end
      obj.histin = val;
    end
    function set.b(obj, val)
      if ~isempty(val)
        if ~isnumeric(val)
          error('### The value for the property ''b'' must be a number(s)');
        end
      end
      obj.b = val;
    end
    function set.ntaps(obj, val)
      error('### Don''t set the property ''ntaps''. It is computed by max(length(a), length(b)).');
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Dependent property methods                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function val = get.ntaps(obj)
      val = max(length(obj.a), length(obj.b));
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = miir(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
      
      % Collect all miir objects
      [fs, ~, rest] = utils.helper.collect_objects(varargin(:), 'miir');
      
      if isempty(rest) && ~isempty(fs)
        % Do copy constructor and return
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        obj = copy(fs, 1);
        for kk=1:numel(obj)
          obj(kk).addHistory(miir.getInfo('miir', 'None'), [], [], obj(kk).hist);
        end
        return
      end
      
      if nargin == 0
        %%%%%%%%%%  f = miir()   %%%%%%%%%%
        utils.helper.msg(msg.OPROC1, 'empty constructor');
        obj.addHistory(miir.getInfo('miir', 'None'), miir.getDefaultPlist('Default'), [], []);
        
      elseif nargin == 1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if ischar(varargin{1}) || iscell(varargin{1})
          %%%%%%%%%%  f = miir('foo.mat')                  %%%%%%%%%%
          %%%%%%%%%%  f = miir('foo.xml')                  %%%%%%%%%%
          %%%%%%%%%%  f = miir({'foo1.xml', 'foo2.xml'})   %%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
          obj = fromFile(obj, plist('filename', varargin{1}));
          
        elseif isstruct(varargin{1})
          %%%%%%%%%%  f = miir(struct)   %%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'constructing from struct');
          obj = fromStruct(obj, varargin{1});
          
        elseif isa(varargin{1}, 'parfrac')
          %%%%%%%%%%  f = miir(plist-object)   %%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'constructing from parfrac');
          obj = fromParfrac(obj, plist('parfrac', varargin{1}));
          
        elseif isa(varargin{1}, 'pzmodel')
          %%%%%%%%%%  f = miir(pzmodel-object)   %%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'constructing from pzmodel %s', varargin{1}.name);
          %           obj = fromPzmodel(obj, plist('pzmodel', varargin{1}));
          obj = fromPzmodel(obj, varargin{1}, []);
          
        elseif isa(varargin{1}, 'plist')
          %%%%%%%%%%  f = miir(plist-object)   %%%%%%%%%%
          pl       = varargin{1};
          
          % Selection of construction method
          if pl.isparam_core('filename') || pl.isparam_core('filenames')
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
            obj = fromFile(obj, pl);
            
          elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
            utils.helper.msg(msg.OPROC1, 'constructing from repository %s', pl.find_core('hostname'));
            obj = obj.fromRepository(pl);
            
          elseif pl.isparam_core('delay')
            
            utils.helper.msg(msg.OPROC1, 'constructing allpass');
            obj = fromAllpass(obj, pl);
            
          elseif pl.isparam_core('type')
            utils.helper.msg(msg.OPROC1, 'constructing from standard %s', pl.find_core('type'));
            obj = fromStandard(obj, pl);
            
          elseif pl.isparam_core('pzmodel')
            utils.helper.msg(msg.OPROC1, 'constructing from pzmodel');
            obj = fromPzmodel(obj, [], pl);
            
          elseif pl.isparam_core('a')
            utils.helper.msg(msg.OPROC1, 'constructing from A/B coefficients');
            obj = fromAB(obj, pl);
            
          elseif pl.isparam_core('parfrac')
            utils.helper.msg(msg.OPROC1, 'constructing from parfrac object');
            obj = fromParfrac(obj, pl);
            
          elseif pl.isparam_core('built-in')
            utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
            obj = fromModel(obj, pl);
            
          else
            pl = applyDefaults(miir.getDefaultPlist('Default') , pl);
            obj.setObjectProperties(pl);
            obj.addHistory(miir.getInfo('miir', 'None'), pl, [], []);
          end
          
        else
          error('### Unknown single argument constructor.');
        end
      elseif nargin == 2
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if isa(varargin{1}, 'pzmodel') && isa(varargin{2}, 'plist')
          %%%%%%%%%%  f = miir(pzmodel-object, plist-object)   %%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'constructing from pzmodel %s', varargin{1}.name);
          obj = fromPzmodel(obj, varargin{1}, varargin{2});
          
        elseif iscellstr(varargin)
          %%%%%%%%%%   miir('dir', 'objs.xml')   %%%%%%%%%%
          obj = fromFile(obj, fullfile(varargin{:}));
          
        elseif (isa(varargin{1}, 'miir') || isa(varargin{1}, 'parfrac')) && isa(varargin{2}, 'plist') &&  isempty(varargin{2}.params)
          %%%%%%%%%%  f = miir(miir-object,    <empty plist>)   %%%%%%%%%%
          %%%%%%%%%%  f = miir(parfrac-object, <empty plist>)   %%%%%%%%%%
          % pass to copy constructor
          obj = miir(varargin{1});
          
        elseif (isa(varargin{1}, 'parfrac')) && isa(varargin{2}, 'plist') &&  ~isempty(varargin{2}.params)
          %%%%%%%%%%  f = miir(parfrac-object, plist-object)   %%%%%%%%%%
          plf = combine(plist('parfrac', varargin{1}),varargin{2});
          obj =  fromParfrac(obj, plf);
          
        elseif (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
          %%%%%%%%%%  f = miir(<database-object>, [IDs])   %%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'retrieve from repository');
          obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
          
        elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
            isa(varargin{2}, 'history')
          %%%%%%%%%%   obj = miir(DOM node, history-objects)   %%%%%%%%%%
          obj = fromDom(obj, varargin{1}, varargin{2});
          
        elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
          %%%%%%%%%%%   miir(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
          % always recreate from plist
          
          % If we are trying to load from file, and the file exists, do
          % that. Otherwise, copy the input object.
          if varargin{2}.isparam_core('filename')
            if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
              obj = miir(varargin{2});
            else
              obj = miir(varargin{1});
            end
          else
            obj = miir(varargin{2});
          end
        else
          error('### Unknown 2 argument constructor.');
        end
        
      elseif nargin == 3
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%   three input   %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if iscellstr(varargin)
          %%%%%%%%%%   miir('to', 'dir', 'objs.xml')   %%%%%%%%%%
          obj = fromFile(obj, fullfile(varargin{:}));
          
        else
          utils.helper.msg(msg.OPROC1, 'constructing from A/B coefficients');
          %%%%%%%%%%  f = miir(a, b, fs)   %%%%%%%%%%
          % a,b,fs constructor
          obj = fromAB(obj, plist('a', varargin{1}, 'b', varargin{2}, 'fs', varargin{3}));
        end
        
      else
        
        if iscellstr(varargin)
          %%%%%%%%%%   miir('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
          obj = fromFile(obj, fullfile(varargin{:}));
          
        else
          [iirs, invars, rest] = utils.helper.collect_objects(args, 'miir');
          
          %%% Do we have a list of MIIR objects as input
          if ~isempty(iirs) && isempty(rest)
            obj = miir(iirs);
          else
            error('### Unknown number of constructor arguments.');
          end
        end
      end
    end % End constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (public)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = setHistin(varargin)
    varargout = setB(varargin)
    varargout = redesign(varargin)
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
    
    function lp = lowpass(varargin)
      % LOWPASS convenient constructor of an IIR lowpass filter.
      %
      % CALL:
      %        lp = miir.lowpass(fs, fc) % order=1, gain=1
      %        lp = miir.lowpass(fs, fc, order) % gain=1
      %        lp = miir.lowpass(fs, fc, order, gain)
      %
      
      pl = miir.convenienceConstructorPlist(varargin{:});
      pl.pset('type', 'lowpass');
      lp = miir(pl);
      
    end
    
    function lp = highpass(varargin)
      % HIGHPASS convenient constructor of an IIR highpass filter.
      %
      % CALL:
      %        lp = miir.highpass(fs, fc) % order=1, gain=1
      %        lp = miir.highpass(fs, fc, order) % gain=1
      %        lp = miir.highpass(fs, fc, order, gain)
      %
      
      pl = miir.convenienceConstructorPlist(varargin{:});
      pl.pset('type', 'highpass');
      lp = miir(pl);
      
    end
    
    function lp = bandpass(varargin)
      % BANDPASS convenient constructor of an IIR bandpass filter.
      %
      % CALL:
      %        lp = miir.bandpass(fs, [f1 f2]) % order=1, gain=1
      %        lp = miir.bandpass(fs, [f1 f2], order) % gain=1
      %        lp = miir.bandpass(fs, [f1 f2], order, gain)
      %
      
      pl = miir.convenienceConstructorPlist(varargin{:});
      pl.pset('type', 'bandpass');
      lp = miir(pl);
      
    end
    
    function lp = bandreject(varargin)
      % BANDREJECT convenient constructor of an IIR bandreject filter.
      %
      % CALL:
      %        lp = miir.bandreject(fs, [f1 f2]) % order=1, gain=1
      %        lp = miir.bandreject(fs, [f1 f2], order) % gain=1
      %        lp = miir.bandreject(fs, [f1 f2], order, gain)
      %
      
      pl = miir.convenienceConstructorPlist(varargin{:});
      pl.pset('type', 'bandreject');
      lp = miir(pl);
      
    end
    
    function varargout = getBuiltInModels(varargin)
      if nargout == 0
        ltpda_uo.getBuiltInModels(mfilename('class'));
      else
        varargout{1} = ltpda_uo.getBuiltInModels(mfilename('class'));
      end
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, mfilename('class'));
    end
    
    function out = SETS()
      out = [SETS@ltpda_uoh,    ...
        {'From LISO File'},     ...
        {'From Standard Type'}, ...
        {'Allpass'}, ...
        {'From Parfrac'},       ...
        {'From Pzmodel'},       ...
        {'From AB'}];
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
        pl = miir.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = miir.newarray([varargin{:}]);
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
    varargout = fromLISO(varargin)
    varargout = fromStruct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(miir.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = miir.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'allpass'
          
          % Delay
          p = param({'delay','The allpass delay.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % N
          p = param({'N','The filter order.'}, paramValue.DOUBLE_VALUE(1));
          out.append(p);
          
          % Method
          p = param({'method','The method for generating the filter.'}, {1, {'thirlen'}, paramValue.SINGLE});
          out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the filter.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the filter.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from ab'
          
          % A
          p = param({'a','Set of numerator coefficients.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % B
          p = param({'b','Set of denominator coefficients.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Fs
          p = param({'fs','The sampling frequency to design for.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the filter.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the filter.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from standard type'
          
          % Type
          p = param({'type','Choose the filter type.'}, {2, {'highpass', 'lowpass', 'bandpass', 'bandreject'}, paramValue.SINGLE});
          out.append(p);
          
          % Fc
          p = param({'fc','The roll-off frequency [Hz].'},  paramValue.DOUBLE_VALUE(0.1));
          out.append(p);
          
          % Gain
          p = param({'gain','The gain of the filter.'},  paramValue.DOUBLE_VALUE(1));
          out.append(p);
          
          % Fs
          p = param({'fs','The sampling frequency to design for.'}, paramValue.DOUBLE_VALUE(1));
          out.append(p);
          
          % Order
          p = param({'order', 'The filter order.'}, paramValue.DOUBLE_VALUE(1));
          out.append(p);
          
          % Ripple
          p = param({'ripple', 'Pass/stop-band ripple (%) for bandpass and bandreject filters.'}, paramValue.DOUBLE_VALUE(0.5));
          out.append(p);
          
          %           % Win
          %           p = param({'win', 'A window to design with.'}, paramValue.WINDOW);
          %           out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the filter.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the filter.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from parfrac'
          
          % Parfrac
          p = param({'parfrac','Parfrac object to design from.'}, {1, {parfrac}, paramValue.OPTIONAL});
          out.append(p);
          
          % Index
          p = param({'Index', 'Index of the filter you want to get. This parameter is usually used by the rebuild() method'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Fs
          p = param({'fs','The sampling frequency to design for.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the transfer function.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the transfer function.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from pzmodel'
          
          % pzmodel
          p = param({'pzmodel','Pole/zero model object to design from.'}, {1, {pzmodel}, paramValue.OPTIONAL});
          out.append(p);
          
          % Fs
          p = param({'fs','The sampling frequency to design for.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the transfer function.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the transfer function.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from liso file'
          
          % Filename
          p = param({'filename','LISO filename.'}, paramValue.EMPTY_STRING);
          out.append(p);
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                               Methods (private)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    varargout = fromPzmodel(varargin)
    f = fromParfrac(f, pli)
    f = fromAB(f, pli)
    f = fromStandard(f, pli)
    f = fromAllpass(f, pli)
    
    f = mklowpass(f, pl)
    f = mkhighpass(f, pl)
    f = mkbandpass(f, pl)
    f = mkbandreject(f, pl)
    f = mkallpass(f, pl)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
    
    f   = filload(filename)
    plo = parseFilterParams(pl)
    
    function pl = convenienceConstructorPlist(varargin)
      pl = plist('fs', 1, 'fc', 0.5, 'order', 1, 'gain', 1);
      
      if nargin < 2
        error('Please give at least a sample rate and a cut-off frequency');
      end
      
      pl.pset('fs', varargin{1});
      pl.pset('fc', varargin{2});
      
      if nargin > 2
        pl.pset('order', varargin{3});
      end
      
      if nargin > 3
        pl.pset('gain', varargin{4});
      end
    end
  end
  
end


