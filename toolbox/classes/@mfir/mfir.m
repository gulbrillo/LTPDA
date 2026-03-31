% MFIR FIR filter object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MFIR FIR filter object class constructor.
%              Create a mfir object.
%
% CONSTRUCTORS:
%
%       f = mfir()         - creates an empty mfir object.
%       f = mfir(fi)       - creates a copy of the input mfir object, fi.
%       f = mfir(a)        - creates a mfir object based on the magnitude of
%                            the input AO/fsdata object a.
%       f = mfir(pzm)      - creates a mfir object from a pole/zero model
%       f = mfir(c,fs)     - creates an mfir object based on the vector of input
%                            coefficients c.
%                            The sample rate for which the filter is designed
%                            should be specified as well.
%       f = mfir(filename) - creates an mfir object loading the  mfir object from disk
%       f = mfir(pl)       - creates an mfir object from the description given
%                            in the parameter list.
%
%
% Parameter sets examples for plist constructor:
%
% EXAMPLE 1:   Create an order 1 highpass filter with high frequency gain 2.
%              Filter is designed for 10 Hz sampled data and has a cut-off
%              frequency of 0.2 Hz.
%
%              >> pl = plist('type', 'highpass', ...
%                            'order', 128,       ...
%                            'gain',  2.0,       ...
%                            'fs',    10,        ...
%                            'fc',    0.2);
%              >> f = mfir(pl)
%
% NOTES:
%           ** The convention used here for naming the filter coefficients is
%              the opposite to MATLAB's convention. The recursion formula
%              for this convention is
%
%              y(n) = a(1)*x(n) + a(2)*x(n-1) + ... + a(na+1)*x(n-na)
%
% <a href="matlab:utils.helper.displayMethodInfo('mfir', 'mfir')">Parameters Description</a>
%
% SEE ALSO:    miir, ltpda_filter, ltpda_uoh, ltpda_uo, ltpda_obj, plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef mfir < ltpda_filter
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    gd      = []; % group delay
  end
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected, Dependent = true)
    ntaps % number of coefficients in the filter
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    function set.gd(obj, val)
      if ~isempty(val)
        if ~isnumeric(val) || ~isreal(val)
          error('### The value for the property ''gd'' must be a real number(s)');
        end
      end
      obj.gd = val;
    end
    function set.ntaps(obj, val)
      error('### Don''t set the property ''ntaps''. It is computed by length(a).');
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Dependent property methods                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function val = get.ntaps(obj)
      val = length(obj.a);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = mfir(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      % Collect all mfir objects
      [fs, ~, rest] = utils.helper.collect_objects(varargin(:), 'mfir');
      
      if isempty(rest) && ~isempty(fs)
        % Do copy constructor and return
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        obj = copy(fs, 1);
        for kk=1:numel(obj)
          obj(kk).addHistory(mfir.getInfo('mfir', 'None'), [], [], obj(kk).hist);
        end
        return
      end
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          obj.addHistory(mfir.getInfo('mfir', 'None'), mfir.getDefaultPlist('Default'), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            %%%%%%%%%%  f = mfir('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%  f = mfir('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%  f = mfir({'foo1.mat', 'foo2.mat'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, plist('filename', varargin{1}));
            
          elseif isa(varargin{1}, 'ao')
            %%%%%%%%%%  f = mfir(ao-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from AO %s', varargin{1}.name);
            pl = mfir.getDefaultPlist('From AO');
            pl = pset(pl, 'AO', varargin{1});
            obj = fromAO(obj, pl);
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%  f = mfir(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isa(varargin{1}, 'pzmodel')
            %%%%%%%%%%  f = mfir(pzmodel-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from pzmodel %s', varargin{1}.name);
            obj = fromPzmodel(obj, plist('pzmodel', varargin{1}));
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%  f = mfir(plist-object)   %%%%%%%%%%
            %----------- plist
            
            pl       = varargin{1};
            
            % Selection of construction method
            if pl.isparam_core('filename') || pl.isparam_core('filenames')
              utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              utils.helper.msg(msg.OPROC1, 'constructing from repository');
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('type')
              utils.helper.msg(msg.OPROC1, 'constructing standard %s filter', pl.find_core('type'));
              obj = fromStandard(obj, pl);
              
            elseif pl.isparam_core('pzmodel')
              utils.helper.msg(msg.OPROC1, 'constructing from pzmodel object');
              obj = fromPzmodel(obj, pl);
              
            elseif pl.isparam_core('a')
              utils.helper.msg(msg.OPROC1, 'constructing from A/B coefficients');
              obj = fromA(obj, pl);
              
            elseif pl.isparam_core('AO')
              utils.helper.msg(msg.OPROC1, 'constructing from AO');
              obj = fromAO(obj, pl);
              
            elseif pl.isparam_core('built-in')
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            else
              pl = applyDefaults(mfir.getDefaultPlist('Default') , pl);
              obj.setObjectProperties(pl);
              obj.addHistory(mfir.getInfo('mfir', 'None'), pl, [], []);
            end
            
          else
            error('### Unknown 1 argument constructor.');
          end
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'ao')
            %%%%%%%%%%  f = mfir(ao-object, plist-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from AO %s', varargin{1}.name);
            obj = fromAO(obj, pset(varargin{2}, 'AO', varargin{1}));
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   mfir('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) ...
              && isnumeric(varargin{2})
            %%%%%%%%%%  f = mfir(<database-object>, [IDs])   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'retrieve from repository');
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif isa(varargin{1}, 'pzmodel') && isa(varargin{2}, 'plist')
            %%%%%%%%%%  f = mfir(pzmodel-object, plist-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from pzmodel %s', varargin{1}.name);
            obj = fromPzmodel(obj, combine(plist('pzmodel', varargin{1}), varargin{2}));
            
          elseif isa(varargin{1}, 'mfir') && isa(varargin{2}, 'plist') && isempty(varargin{2}.params)
            %%%%%%%%%%  f = mfir(mfir, <empty-plist>)   %%%%%%%%%%
            obj = mfir(varargin{1});
            
          elseif isnumeric(varargin{1})
            %%%%%%%%%%  f = mfir(a, fs)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from A coefficients');
            obj = fromA(obj, plist('A', varargin{1}, 'fs', varargin{2}));
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = mfir(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   mfir(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file')==2
                obj = mfir(varargin{2});
              else
                obj = mfir(varargin{1});
              end
            else
              obj = mfir(varargin{2});
            end
          else
            error('### Unknown 2 argument constructor.');
          end
          
        otherwise
          
          if iscellstr(varargin)
            %%%%%%%%%%   mfir('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [firs, ~, rest] = utils.helper.collect_objects(args, 'mfir');
            
            %%% Do we have a list of MFIR objects as input
            if ~isempty(firs) && isempty(rest)
              obj = mfir(firs);
            else
              error('### Unknown number of arguments.');
            end
          end
      end
      
    end % End constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = setGd(varargin)
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
      % LOWPASS convenient constructor of an FIR lowpass filter.
      %
      % CALL:
      %        lp = mfir.lowpass(fs, fc) % order=32, gain=1
      %        lp = mfir.lowpass(fs, fc, order) % gain=1
      %        lp = mfir.lowpass(fs, fc, order, gain)
      %
      
      pl = mfir.convenienceConstructorPlist(varargin{:});
      pl.pset('type', 'lowpass');
      lp = mfir(pl);
      
    end
    
    function lp = highpass(varargin)
      % HIGHPASS convenient constructor of an FIR highpass filter.
      %
      % CALL:
      %        lp = mfir.highpass(fs, fc) % order=32, gain=1
      %        lp = mfir.highpass(fs, fc, order) % gain=1
      %        lp = mfir.highpass(fs, fc, order, gain)
      %
      
      pl = mfir.convenienceConstructorPlist(varargin{:});
      pl.pset('type', 'highpass');
      lp = mfir(pl);
      
    end
    
    function lp = bandpass(varargin)
      % BANDPASS convenient constructor of an FIR bandpass filter.
      %
      % CALL:
      %        lp = mfir.bandpass(fs, [f1 f2]) % order=32, gain=1
      %        lp = mfir.bandpass(fs, [f1 f2], order) % gain=1
      %        lp = mfir.bandpass(fs, [f1 f2], order, gain)
      %
      
      pl = mfir.convenienceConstructorPlist(varargin{:});
      pl.pset('type', 'bandpass');
      lp = mfir(pl);
      
    end
    
    function lp = bandreject(varargin)
      % BANDREJECT convenient constructor of an FIR bandreject filter.
      %
      % CALL:
      %        lp = mfir.bandreject(fs, [f1 f2]) % order=32, gain=1
      %        lp = mfir.bandreject(fs, [f1 f2], order) % gain=1
      %        lp = mfir.bandreject(fs, [f1 f2], order, gain)
      %
      
      pl = mfir.convenienceConstructorPlist(varargin{:});
      pl.pset('type', 'bandreject');
      lp = mfir(pl);
      
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
        {'From Standard Type'}, ...
        {'From Pzmodel'},       ...
        {'From A'},             ...
        {'From AO'}];
    end
    
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
        pl = mfir.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = mfir.newarray([varargin{:}]);
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
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(mfir.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = mfir.addGlobalKeys(out);
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        case 'from standard type'
          
          % Type
          p = param({'type','Choose the filter type.'}, {2, {'highpass', 'lowpass', 'bandpass', 'bandreject'}, paramValue.SINGLE});
          out.append(p);
          
          % Fc
          p = param({'fc','The roll-off frequency [Hz].'},  paramValue.DOUBLE_VALUE([0.1 0.4]));
          out.append(p);
          
          % Gain
          p = param({'gain','The gain of the filter.'},  paramValue.DOUBLE_VALUE(1));
          out.append(p);
          
          % Win
          p = param({'Win','The window function used in the design of the filter.'},  paramValue.WINDOW);
          out.append(p);
          
          % Fs
          p = param({'fs','The sampling frequency to design for.'}, paramValue.DOUBLE_VALUE(1));
          out.append(p);
          
          % Order
          p = param({'order', 'The filter order.'}, paramValue.DOUBLE_VALUE(128));
          out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the filter.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the filter.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from pzmodel'
          
          % Pzmodel
          p = param({'pzmodel', 'A pole/zero model to design from.'}, {1, {pzmodel}, paramValue.OPTIONAL});
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
          
        case 'from ao'
          
          % AO
          p = param({'AO', 'The AO object to design from.'}, {1, {ao}, paramValue.OPTIONAL});
          out.append(p);
          
          % N
          p = param({'N', 'The filter order.'}, paramValue.DOUBLE_VALUE(512));
          out.append(p);
          
          % Method
          p = param({'Method', ['The filter design method:<ul>'...
            '<li>''frequency-sampling'' - uses <a href="matlab:doc(''fir2'')">fir2()</a></li>',...
            '<li>''least-squares''      - uses <a href="matlab:doc(''firls'')">firls()</a></li>',...
            '<li>''Parks-McClellan''    - uses <a href="matlab:doc(''firpm'')">firpm()</a></li></ul>']}, {1, {'frequency-sampling', 'least-squares', 'Parks-McClellan'}, paramValue.SINGLE});
          out.append(p);
          
          % Win
          p = param({'win', 'A window to design with when using the frequency-sampling method.'}, paramValue.WINDOW);
          out.append(p);
          
          % PSLL
          p = param({'psll', 'If you specify a Kaiser window, you can also specify the PSLL.'}, paramValue.DOUBLE_VALUE(100));
          out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the transfer function.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the transfer function.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
        case 'from a'
          
          % A
          p = param({'a','Vector of A coefficients.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Fs
          p = param({'fs','Sampling frequency of the filter.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Iunits
          p = param({'iunits','The input units of the transfer function.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Ounits
          p = param({'ounits','The output units of the transfer function.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                               Methods (private)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    f = fromPzmodel(f, pli)
    f = fromA(f, pli)
    f = fromAO(f, pli)
    f = fromStandard(f, pli)
    
    f = mklowpass(f, pl)
    f = mkhighpass(f, pl)
    f = mkbandpass(f, pl)
    f = mkbandreject(f, pl)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
    
    plo = parseFilterParams(pl)
    
    function pl = convenienceConstructorPlist(varargin)
      pl = plist('fs', 1, 'fc', 0.5, 'order', 32, 'gain', 1);
      
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

