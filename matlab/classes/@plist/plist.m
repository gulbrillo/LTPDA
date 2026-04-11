% PLIST Plist class object constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLIST Parameter-List Object class object constructor.
%              Create a plist object.
%
% SUPER CLASSES: ltpda_uo < ltpda_obj
%
% CONSTRUCTORS:
%
%       pl = plist()                     - create an empty plist object.
%       pl = plist(p)                    - create a plist with elements p
%                                          where p is an array of param objects.
%       pl = plist('key', val)           - create a plist with the key/value
%                                          pair
%       pl = plist({'key', 'desc'}, val) - create a plist with the key/value
%                                          pair and a description for the 'key'
%       pl = plist('key1', val1, ...     - create a plist with more key/value
%                  'key2', val2, ...       pairs
%                  {'key3', 'desc'}, 'val3)
%       pl = plist({'a', 1, 'b', 2})     - create a plist from a cell
%       pl = plist('file.xml')           - load a plist-object from xml-file
%       pl = plist('file.mat')           - load a plist-object from mat-file
%       pl = plist(pl)                   - copies the input plist.
%
% PARAMETERS:
%
%  If no recognised parameters are found in the input plist, the input
%  plist is simply returned. This is the copy constructor.
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'plist')">Parameters Description</a>
%
% SEE ALSO:     ltpda_obj, ltpda_uo, ltpda_uoh, param
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef plist < ltpda_uo
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    params  = []; % list of param-objects
    readonly = false; % flag to indicate that the plist is locked (or not)
  end
  
  properties (SetAccess = private, Transient=true)
    % transient properties which don't need to be copied or saved
    keys    = {};
    defaultKeys = {};
  end
  
  %---------- Removed properties ----------
  % We have to define the removed properties as hidden constants.
  % In case of backwards compatibility it is necessary to keep them because
  % MATLAB will read older MAT-files as structures which we have to convert
  % into an object if we make major change to a class.
  % For MATLAB is a major change if we remove a proeprty.
  properties (Constant = true, Hidden = true)
    creator = [];
    created = [];
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = set.params(obj, val)
      if obj.readonly
        error('Plist is readonly. Copy it before trying to modify it');
      end
      obj.params = val;
    end
    
    function obj = set.readonly(obj, val)
      if ~isempty(obj.params)
        setReadonly(obj.params, true);
      end
      
      obj.readonly = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function pl = plist(varargin)
      
      import utils.const.*
      
      %%%%%%%%%%   Set dafault values   %%%%%%%%%%
      
      %%%%%%%%%%   Overwrite dafault name   %%%%%%%%%%
      pl.name = '';
      
      %%%%%%%%%%   Copy constructor   %%%%%%%%%%
      % Collect all plist objects
      if nargin > 0 && isa(varargin{1}, 'plist')
        [pls, ~, rest] = utils.helper.collect_objects(varargin(:), 'plist');
        
        if isempty(rest) && ~isempty(pls) && numel(pls) ~=1
          % Do copy constructor and return
          utils.helper.msg(msg.OPROC1, 'copy constructor');
          pl = copy(pls, 1);
          return
        end
      end
      
      if nargin == 0
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%   pl = plist()   %%%%%%%%%%
        
      elseif nargin == 1
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if isa(varargin{1}, 'plist') && numel(varargin{1}) == 1
          %%%%%%%%%%  p = param(plist)   %%%%%%%%%%
          
          pli = varargin{1};
          
          if isempty(varargin{1}.params)
            %%% If the plist is empty then return an empty plist object
            
          else
            %%% Retrieve from repository?
            if pli.isparam_core('hostname') || pli.isparam_core('conn')
              pl = pl.fromRepository(pli);
            elseif pli.isparam_core('filename')
              pl = pl.fromFile(pli);
            elseif pli.isparam_core('built-in')
              pl = pl.fromModel(pli);
            else
              pl = copy(varargin{1}, 1);
            end
          end
          
        elseif ischar(varargin{1})
          %%%%%%%%%%% From file %%%%%%%%%%%%%%%%%%%%%%%%
          
          filename = varargin{1};
          pl = fromFile(pl, filename);
          
        elseif isstruct(varargin{1})
          %%%%%%%%%%   pl = plist(struct)   %%%%%%%%%%
          
          pl = fromStruct(pl, varargin{1});
          
        elseif isa(varargin{1}, 'param')
          %%%%%%%%%%   pl = plist(param)   %%%%%%%%%%
          
          pl.params = varargin{1};
          
        else
          error ('### unknown arguments to construct a parameter list')
        end
        
      elseif nargin == 2
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   two inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection'))
          %%%%%%%%%%%   From DATABASE   %%%%%%%%%%%
          pl = pl.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
          
        elseif ischar(varargin{1})
          %%%%%%%%%%   pl = plist('key1', val1)   %%%%%%%%%%
          pl.params = param(varargin{1}, varargin{2});
          
        elseif iscell(varargin{1}) && numel(varargin{1}) == 2 && ~iscell(varargin{2})
          %%%%%%%%%%   pl = plist({'key', 'desc'}, val1)   %%%%%%%%%%
          pl.params = param(varargin{1}{1}, varargin{2}, varargin{1}{2});
          
        elseif iscell(varargin{1}) && iscell(varargin{2})
          %%%%%%%%%%   pl = plist({'key', 'desc'}, {value, {options}, selection})   %%%%%%%%%%
          pl.params = param(varargin{1}, varargin{2});
          
        elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
            isa(varargin{2}, 'history')
          %%%%%%%%%%   obj = plist(DOM node, history-objects)   %%%%%%%%%%
          pl = fromDom(pl, varargin{1}, varargin{2});
          
        else
          error('### Unknown constructor method for two inputs.');
        end
        
      elseif nargin > 2
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   more inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        utils.helper.msg(msg.OPROC1, 'constructing from key/value pairs');
        
        %%%%%%%%%%   pl = plist('key1', val1,           'key2', val2 , ...) %%%%%%%%%%
        %%%%%%%%%%   pl = plist({'key1', 'desc'}, val1, 'key2', val2 , ...) %%%%%%%%%%
        param_list = [];
        argin  = varargin;
        while length(argin) >= 2
          key  = argin{1};
          val  = argin{2};
          desc = '';
          argin = argin(3:end);
          
          % It might be that the key is specified with a description
          if iscell(key) && numel(key) == 2
            desc = key{2};
            key  = key{1};
          end
          
          if ~isempty(param_list)
            found = any(strcmpi(key, {param_list(:).key}));
            if found
              error('### Do not use the same key [%s] twice.\n### REMARK: The key is not case sensitive.', key);
            end
          end
          % add to list
          if isempty(desc)
            param_list = [param_list param(key, val)];
          else
            param_list = [param_list param(key, val, desc)];
          end
        end
        pl.params  = param_list;
      else
        error('### Unknown number of constructor arguments.');
      end
      
    end % End constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (public)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    
    varargout = append(varargin)
    varargout = combine(varargin)
    varargout = find(varargin)
    varargout = isparam(varargin)
    varargout = nparams(varargin)
    varargout = pset(varargin)
    varargout = remove(varargin)
    varargout = string(varargin)
    
    varargout = setDescriptionForParam(varargin)
    varargout = setDefaultForParam(varargin)
    varargout = setOptionsForParam(varargin)
    varargout = setSelectionForParam(varargin)
    
    varargout = getOptionsForParam(varargin)
    varargout = getSelectionForParam(varargin)
    varargout = getDescriptionForParam(varargin)
    varargout = getKeys(varargin)
    
    function prepareForHistory(pl)
      
      % 1. replace ltpda_uoh in pl with their history
      % 2. empty the description field of a parameter ('desc')
      % 3. remove the options
      N = numel(pl.params);
      for jj=1:N
        p = pl.params(jj);
        val = p.getVal;
        
        if isa(val, 'ltpda_uoh')
          
          plval = [val.hist];
          if ~isempty(plval)
            plval = reshape([val.hist], size(val));
          end
          p.setVal(plval);
          
        elseif isa(val, 'plist')
          
          val.prepareForHistory();
          p.setVal(val);
          
        elseif iscell(val)
          
          for kk=1:numel(val)
            if isa(val{kk}, 'ltpda_uoh')
              val{kk} = [val{kk}.hist];
            end
            
          end
          
          p.setVal(val);
          
        else
          p.setVal(p.getVal);
        end
        p.setDesc('');
      end

      
    end
    
    function res = isRepositoryPlist(varargin)
      % Returns an array of logicals, one element per input plist,
      % indication if the plist is considered as a repository plist (i.e.
      % if it has a [HOSTNAME] and [DATABASE] parameter).
      %
      % CALL
      %        results = isRepositoryPlist(pl)
      %
      
      pls = utils.helper.collect_objects(varargin(:), 'plist', {});
      
      res = false(size(pls));
      for kk=1:numel(pls)
        pl = pls(kk);
        if pl.isparam('hostname') && pl.isparam('database')
          res(kk) = true;
        end
      end
    end % End of isRepositoryPlist
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
    
    varargout = find_core(varargin)
    varargout = pset_core(varargin)
    
    varargout = isparam_core(varargin)
    varargout = matchKey_core(varargin)
    varargout = matchKeys_core(varargin)
    varargout = setDefaultForParam_core(varargin)
    
    varargout = sort(varargin)
    varargout = applyDefaults(varargin)
    varargout = processForHistory(varargin)
    varargout = setPropertyForKey(varargin)
    varargout = getPropertyForKey (varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (public, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true)
    
    varargout = getDefaultAxisPlist(varargin);
    varargout = ltp_parameters(varargin)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, mfilename('class'));
    end
    
    function varargout = getBuiltInModels(varargin)
      if nargout == 0
        ltpda_uo.getBuiltInModels(mfilename('class'));
      else
        varargout{1} = ltpda_uo.getBuiltInModels(mfilename('class'));
      end
    end
    
    function out = SETS()
      out = SETS@ltpda_uo;
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
        pl = plist.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    %---------- static factory plists
    
    % Plist to construct an object from a built-in model
    function pl = FROM_BUILT_IN
      pl = plist();
      p = param({'built-in', 'Choose one of the built-in models. (use <i>class</i>.getBuiltInModels to get a list for a particular user class)'}, paramValue.EMPTY_STRING);
      pl.append(p);
      p = param({'version', 'Version of the built in model. The default version is used for the case that no ''Version'' is defined.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      pl.readonly = 1;
    end
    
    % Plist to read from an XML file.
    function pl = FROM_XML_FILE
      pl = plist();
      p = param({'filename','XML filename.'},  paramValue.EMPTY_STRING);
      pl.append(p);
      pl.readonly = 1;
    end
    
    % Plist to read from an XML file.
    function pl = FROM_MAT_FILE
      pl = plist();
      p = param({'filename','MAT filename.'},  paramValue.EMPTY_STRING);
      pl.append(p);
      pl.readonly = 1;
    end
    
    % Plist for connecting to a database.
    function pl = DATABASE_CONNECTION_PLIST
      pl = plist();
      
      % Hostname
      p = param({'hostname', 'Database server hostname.'},  paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Database
      p = param({'database', 'Database name.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Username
      p = param({'username', 'User name to use when connecting to the database. Leave blank to be prompted.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Password
      p = param({'password', 'Password to use when connecting to the database. Leave blank to be prompted.'}, paramValue.EMPTY_CELL);
      pl.append(p);
      
      % Conn
      p = param({'conn', 'Java mysql object.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    % Plist for retrieving objects from a repository. This is used in all
    % user-object constructor default plists for the 'From Repository' set.
    function pl = FROM_REPOSITORY_PLIST
      
      pl = copy(plist.DATABASE_CONNECTION_PLIST, 1);
      
      % ID
      p = param({'ID','A vector of object IDs.'}, paramValue.EMPTY_DOUBLE);
      p.addAlternativeKey('ids');
      pl.append(p);
      
      % CID
      p = param({'CID','A vector of collection IDs.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % UUID
      p = param({'UUID','A cell array of UUIDs.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('UUIDs');
      pl.append(p);
      
      % Binary
      p = param({'binary','Use binary representation (not always available).'}, paramValue.TRUE_FALSE);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    % Plist for submitting/updating objects from a repository. This is used
    % in ltpda_uo/ -submit, -bsubmit and -update.
    function pl = TO_REPOSITORY_PLIST
      
      pl = copy(plist.DATABASE_CONNECTION_PLIST, 1);
      
      % experiment title
      p = param({'experiment title', 'Title for the submission'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % experiment description
      p = param({'experiment description', 'Description of this submission'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % analysis description
      p = param({'analysis description', 'Description of the analysis performed'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % quantity
      p = param({'quantity', 'Physical quantity represented by the data'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % keywords
      p = param({'keywords', 'Comma-delimited list of keywords'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % reference ids
      p = param({'reference ids', 'Comma-delimited list of object IDs'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % additional comments
      p = param({'additional comments', 'Additional comments'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % additional authors
      p = param({'additional authors', 'Additional author names'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % control for no dialog
      p = param({'no dialog', 'Do not use of the submission form. Mandatory fields must be supplied in the plist.'}, paramValue.FALSE_TRUE);
      pl.append(p);
      
      pl.readonly = 1;
    end
        
    % Plist list for windowing
    function pl = WINDOW_PLIST
      pl = plist();
      
      % Win
      p = param({'Win',['The window to be applied to the data to remove the ', ...
        'discontinuities at edges of segments. [default: taken from user prefs] <br>', ...
        'Only the design parameters of the window object are used. Enter ', ...
        'a string value containing the window name e.g.<br>', ...
        '<tt>plist(''Win'', ''Kaiser'', ''psll'', 200)</tt><br>', ...
        '<tt>plist(''Win'', ''BH92'')</tt>']}, paramValue.WINDOW);
      pl.append(p);
      
      % Psll
      p = param({'Psll',['The peak sidelobe level for Kaiser windows.<br>', ...
        'Note: it is ignored for all other windows']}, paramValue.DOUBLE_VALUE(200));
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    % Plist for likelihood functions
    function pl = LLH_PLIST
      pl = plist();
      
      % parameter 'FREQUENCIES'
      p = param({'FREQUENCIES','The frequency range.'},  paramValue.DOUBLE_VALUE([]));
      pl.append(p);
      
      % parameter 'NAME'
      p = param({'FUNCTION NAME','The name of the likelihood function handle.'},  paramValue.STRING_VALUE('LLH'));
      p.addAlternativeKey('FUNC NAME');
      pl.append(p);
      
      % parameter 'Time Series MFH'
      p = param({'Time Series MFH','The time series function handles to perform the FFT. Must be in an array.'},  paramValue.EMPTY_DOUBLE);
      p.addAlternativeKey('MODEL');
      pl.append(p);
      
      % parameter 'NOISE MODEL'
      p = param({'NOISE MODEL',['The given noise model. It may be a) an AO time-series with the appropriate Y units, b) '...
        'an AO frequency-series of the correct size (NoutputsXNoutputs), c) a SMODEL (function of freqs) '...
        'of the correct size (NoutputsXNoutputs) d) a MFH object. ']},  paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % parameter 'P0'
      p = param({'P0','A set of parameters to evaluate the MFH. Used to get the number of samples.'},  paramValue.EMPTY_DOUBLE);
      p.addAlternativeKey('X0');
      p.addAlternativeKey('paramVals');
      pl.append(p);
      
      % parameter 'TRIM'
      p = param({'TRIM','A 2x1 vector that denotes the samples to split from the star and end of the time-series (split in offsets).'},  paramValue.DOUBLE_VALUE([100 -100]));
      pl.append(p);
      
      % parameter 'WIN'
      p = param({'WIN','The window to apply to the data.'},  paramValue.STRING_VALUE('BH92'));
      pl.append(p);
      
      % parameter 'k0'
      p = param({'k0','The first FFT coefficient of the analysis. All FFT coefficients with k<k0 are discarded from the analysis.'},  paramValue.DOUBLE_VALUE(1));
      pl.append(p);
      
      % parameter 'transform'
      p = param({'TRANSFORM', 'A list of transformations to be applied to the inputs before evaluating the expression.'}, paramValue.EMPTY_CELL);
      p.addAlternativeKey('transformations');
      pl.append(p);
      
      % parameter 'Navs'
      p = param({'NAVS', 'The Number of averages for the PSD of the noise.'}, 10);
      pl.append(p);
      
      % parameter 'OLAP'
      p = param({'OLAP', 'The segment percent overlap [-1 == take from window function]'}, -1);
      pl.append(p);
      
      % parameter 'int method'
      p = param({'INTERPOLATION METHOD', 'The interpolation method for the computation of the inverse cross-spectrum matrix.'}, ...
        {2, {'nearest', 'linear', 'spline', 'pchip', 'cubic', 'v5cubic'}, paramValue.SINGLE});
      pl.append(p);
      
      % parameter 'ORDER'
      p = param({'ORDER',['The order of segment detrending:<ul>', ...
        '<li>-1 - no detrending</li>', ...
        '<li>0 - subtract mean</li>', ...
        '<li>1 - subtract linear fit</li>', ...
        '<li>N - subtract fit of polynomial, order N</li></ul>']}, paramValue.DETREND_ORDER);
      p.val.setValIndex(2);
      pl.append(p);
      
      % ISDIAG
      p = param({'ISDIAG',['For the case of systems where the cross-spectrum matrix is diagonal it can be set to true '...
        'to skip estimating the non-diagonal elements. Useful for multiple inputs/outputs.']}, paramValue.FALSE_TRUE);
      pl.append(p);
      
      % parameter 'yunits'
      p = param({'YUNITS', 'The Y units of the noise time series, in case the MFH object is a ''core'' type.'}, 'm s^-2');
      pl.append(p);
      
      % parameter 'DOPLOT'
      p = param({'DOPLOT', 'True-False flag to plot the FFT of the signal time-series.'}, paramValue.TRUE_FALSE);
      pl.append(p);
      
      % BIN DATA
      p = plist({'BIN DATA','Set to true to re-bin the measured noise data.'}, paramValue.TRUE_FALSE);
      pl.append(p);
      
      % FIT NOISE MODEL
      p = plist({'FIT NOISE MODEL','Set to true to attempt a fit on the noise spectra using the ''polyfitSpectrum'' function.'}, paramValue.FALSE_TRUE);
      pl.append(p);
      
      % POLYNOMIAL ORDER
      p = plist({'POLYNOMIAL ORDER','The order of the polynomial to be used in the ''polyfitSpectrum'' function.'}, paramValue.DOUBLE_VALUE(-10:10));
      pl.append(p);
      
      % NOISE SCALE
      p = plist({'NOISE SCALE',['Select the way to handle the noise/weight data. '...
        'Can use the PSD/CPSD or the LPSD/CLPSD functions.']}, {1, {'PSD','LPSD'}, paramValue.SINGLE});
      pl.append(p);
    end
    
    % Plist for Welch-based, linearly spaced spectral estimators.
    % This is used in psd, cpsd, cohere, tfe
    function pl = WELCH_PLIST
      pl = plist();
      
      % Nfft
      p = param({'Nfft',['The number of samples in each fft [default: length of input data]. <br>', ...
        'A string value containing the variable ''fs'' can also be used, e.g., <br> ', ...
        '<tt>plist(''Nfft'', ''2*fs'')</tt>']}, paramValue.DOUBLE_VALUE(-1));
      pl.append(p);
      
      % Win
      pl.append(plist.WINDOW_PLIST);
      
      % Olap
      p = param({'Olap','The segment percent overlap [-1 == take from window function]'}, {1, {-1}, paramValue.OPTIONAL});
      pl.append(p);
      
      % Order, N
      p = param({'Order',['The order of segment detrending:<ul>', ...
        '<li>-1 - no detrending</li>', ...
        '<li>0 - subtract mean</li>', ...
        '<li>1 - subtract linear fit</li>', ...
        '<li>N - subtract fit of polynomial, order N</li></ul>']}, paramValue.DETREND_ORDER);
      p.val.setValIndex(2);
      p.addAlternativeKey('N');
      pl.append(p);
      
      % Navs
      p = param({'Navs',['Force number of averages. If set, and if Nfft was set to 0 or -1,<br>', ...
        'the number of points for each window will be calculated to match the request.']}, paramValue.DOUBLE_VALUE(-1));
      pl.append(p);
      
      % drop window samples
      p = param({'Drop Window Samples','Drop the recommended (by the window) number of samples of the final computed spectral series.'}, paramValue.TRUE_FALSE);
      pl.append(p);
      
      % Times, Split
      p = param({'Times',['The time range to analyze. If not empty, sets the time interval to operate on.<br>', ...
        'As in ao/split, the interval can be specified by:<ul>' ...
        '<li>a vector of doubles</li>' ...
        '<li>a timespan object</li>' ...
        '<li>a cell array of time strings</li>' ...
        '<li>a vector of time objects</li></ul>' ...
        ]}, paramValue.DOUBLE_VALUE([]));
      p.addAlternativeKey('Split');
      pl.append(p);
      
      % Scale
      p = param({'mask', 'Mask out segments in the averaging process. The mask should be a vector of logical values, one value per segment being averaged. The plist method [psdSegments] can be used to generate a default mask for your PSD settings. If empty, all segments will be included in the average.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      pl.readonly = 1;
      
    end
    
    % Plist for Welch-based, log-scale spaced spectral estimators.
    % This is used in lpsd, lcpsd, lcohere, ltfe
    function pl = LPSD_PLIST
      
      pl = copy(plist.WELCH_PLIST);
      
      pl.remove('Navs', 'nfft');
      
      % Kdes
      p = param({'Kdes', 'The desired number of averages.'}, {1, {100}, paramValue.OPTIONAL});
      pl.append(p);
      
      % Jdes
      p = param({'Jdes', 'The desired number of spectral frequencies to compute.'}, {1, {1000}, paramValue.OPTIONAL});
      pl.append(p);
      
      % Lmin
      p = param({'Lmin', 'The minimum segment length.'}, {1, {0}, paramValue.OPTIONAL});
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    % Plist for linear fitting methods
    % This is used in linfit, polynomfit
    
    function pl = LINEAR_FIT_PLIST
      
      pl = plist();
      
      % dy
      p = param({'dy', ['Uncertainty on Y. Can be expressed as<ul>' ...
        '<li>an AO with single value or</li>' ...
        '<li>an AO with a vector of the right length or</li>' ...
        '<li>a double or</li>' ...
        '<li>an array of double of the right length</li></ul>' ]}, ...
        paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % dx
      p = param({'dx', ['Uncertainty on X(1..N). Can be expressed as<ul>' ...
        '<li>an AO with single value or</li>' ...
        '<li>an AO with a vector of the right length or</li>' ...
        '<li>a double or</li>' ...
        '<li>an array of double of the right length</li></ul>' ]}, ...
        paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % p0
      p = param({'p0', ['Initial guess of the fit parameters. Can be expressed as:<ul>' ...
        '<li>an AOs with a vector</li>' ...
        '<li>an array of scalars or</li>' ...
        '<li>a pest object</li></ul>']}, ...
        paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    % Plist for multilinear fitting methods
    % This is used in bilinfit
    
    function pl = MULTILINEAR_FIT_PLIST
      
      pl = plist();
      
      % dy
      p = param({'dy', ['Uncertainty on Y. Can be expressed as<ul>' ...
        '<li>an AO with single value or</li>' ...
        '<li>an AO with a vector of the right length or</li>' ...
        '<li>a double or</li>' ...
        '<li>an array of double of the right length</li></ul>' ]}, ...
        paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % dx
      p = param({'dx', ['Uncertainty on X1 ... XN. Can be expressed as<ul>' ...
        '<li>an array of N AOs with single value or</li>' ...
        '<li>an array of N AOs with data vectors of the right length or</li>' ...
        '<li>an array of N double</li></ul>' ]}, ...
        paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % p0
      p = param({'p0', ['Initial guess of the fit parameters. Can be expressed as:<ul>' ...
        '<li>an AOs with a vector</li>' ...
        '<li>an array of scalars or</li>' ...
        '<li>a pest object</li></ul>']}, ...
        paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    % Plist for multichannel fitting methods
    % This is used in linfitsvd, mcmc, and tdfit
    
    function pl = MCH_FIT_PLIST
      
      pl = plist();
      
      % Model
      p = param({'Model','System model. It have to be parametric. A matrix of smodel objects or a ssm object'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % Input Names
      p = param({'InNames','A cell array containing cell arrays of the input ports names for each experiment. Used only with ssm models.'}, {});
      pl.append(p);
      
      % Output Names
      p = param({'OutNames','A cell array containing cell arrays of the output ports names for each experiment. Used only with ssm models.'}, {});
      pl.append(p);
      
      % Fit Params
      p = param({'FitParams','A cell array with the names of the fit parameters'}, {});
      pl.append(p);
      
      % Injected Signals
      p = param({'Input','Collection of input signals'},paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    % Plist for time series
    % This is used in ao constructor
    function pl = TSDATA_PLIST
      
      pl = plist();
      % Fs
      p = param({'fs', 'The sampling frequency of the signal. [for all]'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % Nsecs
      p = param({'nsecs', 'The number of seconds of data. [for all]'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      % Xunits
      p = param({'xunits','Unit on X axis.'},  unit.seconds);
      pl.append(p);
      
      % T0
      p = param({'T0', 'The UTC time of the first sample. [for all]'}, {1, {'1970-01-01 00:00:00.000 UTC'}, paramValue.OPTIONAL});
      pl.append(p);
      
      % toffset
      p = param({'toffset', 'The offset between the first x sample and t0.'}, paramValue.DOUBLE_VALUE(0));
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    % Plist for processing history trees
    function pl = HISTORY_TREE_PLIST
      
      pl = plist();
      p = param({'stop_option', ['Stop option which defines the option at which point the reproduceing stop.<ul>', ...
        '<li>''full'': Reproduce all history steps</li>', ...
        '<li>''File'': Ignores the history steps below load-history step</li>', ...
        '<li>''Repo'': Ignores the history steps below retrieve-history step</li>', ...
        '<li>''File Repo'': Both steps above</li>', ...
        '<li>''N'': Maximun depth</li></ul>']}, {1, {'full', 'File', 'Repo', 'File Repo', 'N'}, paramValue.SINGLE});
      p.addAlternativeKey('stop option');
      pl.append(p);
    end
    
    % Plist for dotview methods (ltpda_uoh, ssm)
    function pl = DOTVIEW_PLIST
      
      pl = plist();
      
      % Title
      p = param({'Title','A title string for the final graph'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Filename
      p = param({'filename','the file name for the graphic file'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % View
      p = param({'view','true or false to view or not'}, paramValue.TRUE_FALSE);
      p.val.setValIndex(1);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    % Plist for saving objects
    function pl = SAVE_OBJ_PLIST
      
      pl = plist();
      
      % Filename
      p = param({'filename',['Name of the file to save in.<br>', ...
        'The format is determined based on the file extension:<ul>', ...
        '<li>.xml for XML format</li>', ...'
        '<li>.mat for Matlab format</li></ul>']}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Filename prefix
      p = param({'prefix', 'Filename prefix'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Filename postfix
      p = param({'postfix', 'Filename postfix'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Individual Files
      p = param({'individual files', 'Save the objects into Individual files'}, paramValue.FALSE_TRUE);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    function pl = AXIS_3D_PLIST
      
      pl = plist();
      p = param({'axis', 'The axis on which to apply the method.'},  ...
        {3, {'x', 'y', 'z', 'xyz'}, paramValue.SINGLE});
      pl.append(p);
      
      p = param({'dim', ['The dimension of the chosen vector to apply the method '...
        'to. This is necessary for functions like mean() when ' ...
        'applied to matrices held in the z field of xyzdata objects.']}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      p = param({'option', 'Any additional option to pass to the method.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    function pl = AXIS_2D_PLIST
      
      pl = plist();
      p = param({'axis', 'The axis on which to apply the method.'},  ...
        {2, {'x', 'y', 'xy'}, paramValue.SINGLE});
      pl.append(p);
      
      p = param({'option', 'Any additional option to pass to the method.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    function pl = EMPTY_PLIST
      pl = plist();
      pl.readonly = 1;
    end
    
    function pl = AXIS_1D_PLIST
      
      pl = plist();
      p = param({'axis', 'The axis on which to apply the method.'},  ...
        {1, {'y'}, paramValue.SINGLE});
      pl.append(p);
      
      p = param({'dim', ['The dimension of the chosen vector to apply the method '...
        'to. This is necessary for functions like mean() when ' ...
        'applied to matrices held in cdata objects. For tsdata, '...
        'fsdata or xydata, this option has no effect.']}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      p = param({'option', 'Any additional option to pass to the method.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      pl.readonly = 1;
    end
    
    function pl = RAND_STREAM
      pl = plist({'RAND_STREAM', ['Internal MATLAB state of the pseudorandom number generator. ', ...
        'You can set the state with a structure which should contain all ', ...
        'properties of the MATLAB class RandStream']}, []);
      pl.readonly = 1;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = plist.newarray([varargin{:}]);
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    
    varargout = fromStruct(varargin)
    varargout = processSetterValues(varargin)
    
    function cacheKey(pl, key)
      
      if ~isempty(pl.keys)
        pl.keys{end+1} = key;
      end
      
      if ~isempty(pl.defaultKeys)
        pl.defaultKeys{end+1} = key;
      end
      
    end
    
    function resetCachedKeys(pl)
      pl.keys = {};
      pl.defaultKeys = {};
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      if ~utils.helper.ismember(lower(plist.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = buildplist@ltpda_uo(out, set);
      
      switch lower(set)
        % No special sets are dfined.
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Methods (private)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden=true)
    varargout = plist2cmds(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
  end
  
end


