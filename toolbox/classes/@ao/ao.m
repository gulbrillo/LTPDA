% AO analysis object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: AO analysis object class constructor.
%              Create an analysis object.
%
%     Possible constructors:
%       a = ao()             - creates an empty analysis object
%       a = ao('a1.xml')     - creates a new AO by loading a file
%       a = ao('path', 'to', 'directory', 'a1.xml') - creates a new AO
%                                                     by loading a file specified by the path parts
%       a = ao('a1.mat')
%       a = ao('path', 'to', 'directory', 'a1.mat') - creates a new AO
%                                                     by loading a file specified by the path parts
%       a = ao('a1.mat')     - creates a new AO by loading the 2-column data .MAT file.
%       a = ao('file.txt')   - creates a new AO by loading the data.
%       a = ao('file.dat')
%       a = ao('file',pl)     (<a href="matlab:utils.helper.displayMethodInfo('ao', 'ao')">Set: From ASCII File</a>)
%       a = ao(data)         - creates an AO with a data object.
%       a = ao(constant)     - creates an AO from a constant
%       a = ao(specwin)      - creates an AO from a specwin object
%       a = ao(pzm)          - creates an AO from a pole/zero model object
%       a = ao(pzm,nsecs,fs)
%       a = ao(smodel)       - creates an AO from a symbolic model object
%       a = ao(pest)         - creates an AO from a parameter estimates object
%       a = ao(x,y)          - creates an AO with xy data
%       a = ao(y, fs)        - creates an AO with time-series data
%       a = ao(x,y,fs)       - creates an AO with time-series data
%       a = ao(x,y,pl)       - creates an AO depending from the PLIST (<a href="matlab:utils.helper.displayMethodInfo('ao', 'ao')">Set: From XY Values</a>).
%       a = ao(plist)        - creates an AO from a <a href="matlab:utils.helper.displayMethodInfo('ao', 'ao')">parameter list</a>
%       a = ao(vals, yunits) - creates a cdata AO with the given values and yunits.
%
% <a href="matlab:utils.helper.displayConstructorExamples('ao')">Examples</a>
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'ao')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% AO analysis object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: AO analysis object class constructor.
%              Create an analysis object.
%
%     Possible constructors:
%
%       a = ao()            - creates an empty analysis object
%       a = ao('a1.xml')    - creates a new analysis object by loading the
%                             analysis object from disk.
%       a = ao('a1.mat')    - creates a new analysis object by loading the
%                             analysis object from disk.
%       a = ao('a1.mat')    - creates a new analysis object by loading the
%                             2-column data set stored in the .MAT file.
%       a = ao('file.txt')  - creates a new analysis object by loading the
%       a = ao('file.dat')    data in 'file.txt'. The ascii file is assumed
%                             to be an equally sampled two-column file of
%                             time and amplitude. By default, the amplitude
%                             units are taken to be Volts ('V') and the
%                             time samples are assumed to be in seconds.
%       a = ao('file',pl)   - creates a new analysis object by loading the
%                             data in 'file'. The parameter list decide how the
%                             analysis object is created. The valid key values
%                             of the parameter list are:
%                             'type'        'tsdata','fsdata','xydata'
%                                            [default: 'tsdata']
%                             'fs'           if this value is set, the
%                                            x-axes is computed by the fs value.
%                                            [default: empty array]
%                             'columns'      [1 2 1 4]
%                                            Each pair represented the x- and y-axes.
%                                            (Each column pair creates an analysis object)
%                                            If the value 'fs' is used then
%                                            represent each column the y-axes.
%                                            (Each column creates an analysis object)
%                                            [default: [1] ]
%                             'comment_char' The comment character in the file
%                                            [default: '']
%                             'description'  To set the description in the analysis object
%                             '...'          every property where exist a public
%                                            set-function in the AO class e.g.
%                                            setName, setT0, setYunits, ...
%                             If the constructor creates multiple ao's it is
%                             possible to give each data class its own e.g.
%                             'name'. In this case the parameter list with the
%                             key 'name' must have cell of the different values
%                             as the name of the different data objects. e.g.
%                             pl = plist('columns', [1 2 1 3],        ...
%                                        'name',   {'name1' 'name2'}, ...
%                                        'xunits', unit('s'),             ...
%                                        'yunits', {unit('V') unit('Hz'}));
%                             This parameter list creates two ao's with tsdata.
%
%                             'Robust'  - set this to 'true' to use (slow)
%                                         robust data reading. Useful for
%                                         complicated file formats.
%                                         [default: 'true']
%
%       NOTE: Data files with comments at the end of the lines can only be
%       read if there are no lines with only comments. In this case, do not
%       specify a comment character. If you really want to load a file like
%       this, specify the 'Robust' option; this will be very slow for large
%       files.
%
%       a = ao(data)        - creates an analysis object with a data
%                             object. Data object can be one of tsdata,
%                             fsdata, cdata, xydata, xyzdata.
%       a = ao(data, hist)  - creates an analysis object with a data
%                             object and a history object
%       a = ao(specwin)     - creates an analysis object from a specwin
%                             object
%       a = ao(plist)       - creates an analysis object from the description
%                             given in the parameter list
%
%
% Parameter sets for plist constructor (in order of priority):
%
% Notes and examples for some parameter sets follow:
%
% From complex ASCII File
% ---------------
%
%     >> ao(plist('filename','data.txt','complex_type','real/imag','type','tsdata'));   %!
%     >> ao(plist('filename','data.txt','complex_type','real/imag','type','fsdata','columns',[1,2,4]));   %!
%
% From Function
% -------------
%
%     >> ao(plist('fcn', 'randn(100,1)','yunits','V'));
%
% From Values
% -----------
%
%     >> ao(plist('vals',[1 2 3],'N',10));                              % -->  cdata
%     >> ao(plist('xvals',[1 2 3],'yvals',[10 20 30]));                 % --> xydata
%     >> ao(plist('xvals',[1 2 3],'yvals',[10 20 30],'type','tsdata')); % --> tsdata
%     >> ao(plist('xvals',[1 2 3],'yvals',[10 20 30],'type','fsdata')); % --> fsdata
%     >> ao(plist('fs',1,'yvals',[10 20 30]));                          % --> tsdata
%     >> ao(plist('fs',1,'yvals',[10 20 30],'type','fsdata'));          % --> fsdata
%     >> ao(plist('fs',1,'yvals',[10 20 30],'type','fsdata','xunits','mHz','yunits','V'));
%
% From XY Function
% ----------------
%
%     >> ao(plist('xyfcn', 'cos(2*pi*x) + randn(size(x))','x',[1:1e5]));
%
% From Time-series Function
% -------------------------
%
%     >> ao(plist('tsfcn', 'cos(pi*t) + randn(size(t))', 'fs', 1, 'nsecs', 100));
%     >> ao(plist('fs',10,'nsecs',10,'tsfcn','sin(2*pi*1.4*t)+0.1*randn(size(t))','t0',time('1980-12-01 12:43:12')));
%
%
% From Frequency-series Function
% ------------------------------
%
%     >> ao(plist('FSFCN','f','f1',1e-5,'f2',1,'yunits','V'));
%     >> ao(plist('FSFCN','f','f',[0.01:0.01:1]));
%
% From Window
% -----------
%
%     >> ao(plist('win', specwin('Hannning', 100)));
%
% From Waveform
% -------------
%
%     >> ao(plist('waveform','sine wave','A',3,'f',1,'phi',pi/2,'toff',0.1,'nsecs',10,'fs',100));
%     >> ao(plist('waveform','noise','type','normal','sigma',2,'nsecs',1000,'fs',1));
%     >> ao(plist('waveform','chirp','f0',0.1,'f1',1,'t1',1,'nsecs',5,'fs',1000));
%     >> ao(plist('waveform','gaussian pulse','f0',1','bw',0.2,'nsecs',20,'fs',10));
%     >> ao(plist('waveform','square wave','f',2,'duty',40,'nsecs',10,'fs',100));
%     >> ao(plist('waveform','sawtooth','f',1.23,'width',1,'nsecs',10/1.23,'fs',50));
%
%
%
% From Repository
% ---------------
%
%      >> ao(plist('hostname','123.123.123.123','database','ltpda_test','ID',[1:10],'binary',true));
%
%
% From Polynomial
% ---------------
%
%   Construct an AO from a set of polynomial coefficients.
%
%   'polyval'  - a set of polynomial coefficients. This can also be an AO,
%                in which case the Y values from the AO are used.
%                [default: [-0.0001 0.02 -1 -1] ]
%
%   Additional parameters:
%         'Nsecs'           - number of seconds           [default: 10]
%         'fs'              - sample rate                 [default: 10]
%   or
%         't'               - vector of time vertices. The value can also
%                             be an AO, in which case the X vector is used.
%                             [default: [] ]
%
%   Example:
%   plist('polyval', [1 2 3], 'Nsecs', 1e2, 'fs', 10)
%
% From Pzmodel
% ------------
%
%  Generates an ao with a timeseries with a prescribed spectrum.
%
%  'pzmodel'   - a pole/zero model which builds the time-series AO
%
%                Additional parameters:
%                   'Nsecs'           - number of seconds to be generated
%                   'fs'              - sampling frequency
%
%                You can also specify optional parameters:
%                   'xunits'          - unit of the x-axis
%                   'yunits'          - unit of the y-axis
%
%   Example:  p   = [pz(f1,q1) pz(f2,q2)]
%             z   = [pz(f3,q3)]
%             pzm = pzmodel(gain, p, z)
%   plist('pzmodel', pzm, 'Nsecs', 1e2, 'Fs', 10)
%
% From Built-in Model
% -------------------
%
% To get a list of built-in AOs: ao.getBuiltInModels
%
% Each model has additional parameters that need to be passed. To see the
%
% Additonal model parameters: >> help ao_model_<model_name>
%
% Example: >> help ao_model_mdc1_fd_dynamics
%
% From Plist
% ----------
%
%   Examples:
%
%   1) Normally distributed random noise time-series
%
%      >> p = plist('waveform', 'noise', 'fs', 10, 'nsecs', 1000);
%      >> a = ao(p);
%
%      Indexing:
%
%      >> b = a(1);           % where a is an array of analysis objects
%      >> d = a.data;         % get the data object
%      >> h = a.hist;         % get the history object
%      >> d = a.data.x(1:20); % get a matrix of data values x;
%
%  2) Timeseries with a prescribed spectrum
%
%     >> a = ao(plist('pzmodel', pzm, 'fs',10, 'nsecs', 120, 'ndigits', 50)); %!
%
%        fs      - sampling frequency
%        nsecs   - number of seconds in time series
%        ndigits - number of digits for symbolic math toolbox (default: 32)
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'ao')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% See also tsdata, fsdata, xydata, cdata, xyzdata


classdef ao < ltpda_uoh
  
  %------------------------------------------------
  %---------- Private read-only Properties --------
  %------------------------------------------------
  properties (GetAccess = public, SetAccess = protected)
    data        = []; % Data object associated with this AO
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.data(obj, val)
      if ~(isa(val, 'ltpda_data') || isempty(val))
        error('### The value for the property ''data'' must be a ltpda_data object');
      end
      obj.data = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    function obj = ao(varargin)
      
      % check if the caller was a user of another method
      callerIsMethod = utils.helper.callerIsMethod;
      
      import utils.const.*
      if ~callerIsMethod
        utils.helper.msg(msg.PROC3, 'running ao/ao');
      end
      
      %%% Create a listener for the timespan object.
      %%% This is necessary for AOs with time-series because in that case
      %%% do we want to use the t0 plus the number of seconds.
      addlistener(obj, 'timespan', 'PreGet', @obj.getPropEvt);
      
      %%% Collect all plists and combine them.
      [pli, ~, args] = utils.helper.collect_objects(varargin, 'plist');
      
      % allow for override of callerIsMethod, but we only allow forcing
      % callerIsMethod to false.
      if ~isempty(pli)
        pl_callerIsMethod = pli.find_core('callerIsMethod');
        if ~pl_callerIsMethod
          callerIsMethod = false;
        end
      end
      
        
      if ~isempty(pli)
        if numel(pli)>1
          pli = pli.combine();
        else
          pli = copy(pli, 1);
        end
        if ~isempty(pli.find_core('dtype'))
          warning('LTPDA:ao', 'the parameter name ''dtype'' is now deprecated; please use ''type'' instead.')
          pli.append('type',pli.find_core('dtype'));
          pli.remove('dtype');
        end
        if ~isempty(pli.find_core('use_fs'))
          warning('LTPDA:ao', 'the parameter name ''use_fs'' is now deprecated; please use ''fs'' instead.')
          pli.append('fs',pli.find_core('use_fs'));
          pli.remove('use_fs');
        end
        %%% Append the plist to the input-arguments
        args{end+1} = pli;
      end
      
      %%% Execute appropriate constructor
      switch numel(args)
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if ~callerIsMethod
            obj.addHistory(ao.getInfo('ao', 'None'), ao.getDefaultPlist('Default'), [], []);
          end
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(args{1}) || iscell(args{1})
            %%%%%%%%%%   a1 = ao('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   a1 = ao('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   a1 = ao('foo.txt')                  %%%%%%%%%%
            %%%%%%%%%%   a1 = ao('foo.dat')                  %%%%%%%%%%
            %%%%%%%%%%   a1 = ao({'foo1.mat', 'foo2.mat'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, args{1});
            
          elseif isa(args{1}, 'ao')
            %%%%%%%%%%   a1 = ao(ao)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'copying %s', args{1}.name);
            obj = copy(args{1},1);
            for kk = 1:numel(args{1})
              obj(kk).addHistory(ao.getInfo('ao', 'None'), [], [], obj(kk).hist);
            end
            
          elseif isstruct(args{1})
            %%%%%%%%%%   a1 = ao(struct)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isnumeric(args{1})
            %%%%%%%%%%   a1 = ao(constant)   %%%%%%%%%%
            %%%%%%%%%%   a1 = ao([1 2; 3 4])   %%%%%%%%%%
            
            utils.helper.msg(msg.PROC3, 'constructing from values');
            obj = fromVals(obj, plist('VALS', args{1}), callerIsMethod);
            
          elseif isa(args{1}, 'pzmodel')
            %%%%%%%%% ao(pzmodel)   %%%%%%%%%%%%
            obj = obj.fromPzmodel(plist('pzmodel', args{1}));
            
            
          elseif isa(args{1}, 'plist')
            %%%%%%%%%%   a1 = ao(plist-object)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from plist');
            pl         = args{1};
            
            if pl.isparam_core('built-in')
              
              %--- Construct from model
              utils.helper.msg(msg.PROC2, 'constructing from built-in model');
              obj = obj.fromModel(pl);
              
              if isempty(obj)
                error('Failed to build model [%s]', pl.find('built-in'));
              end
              
            elseif pl.isparam_core('filename') || pl.isparam_core('filenames')
              
              %-----------------------------------------------------
              %--- Construct from file
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, args{1});
              
              
            elseif pl.isparam_core('fcn')
              
              %-----------------------------------------------------
              %--- Construct from function
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from function %s', pl.find_core('fcn'));
              obj = fromFcn(obj, pl);
              
            elseif pl.isparam_core('vals')
              
              %-----------------------------------------------------
              %--- Construct from Values
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from values');
              obj = obj.fromVals(pl, callerIsMethod);
              
            elseif pl.isparam_core('xvals') && pl.isparam_core('yvals') && pl.isparam_core('zvals')
              
              %-----------------------------------------------------
              %--- Construct from X, Y and Z Values
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from X, Y and Z values');
              obj = fromXYZVals(obj, pl, callerIsMethod);
              
            elseif pl.isparam_core('xvals') || pl.isparam_core('yvals')
              
              %-----------------------------------------------------
              %--- Construct from X and Y Values
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from X and Y values');
              obj = fromXYVals(obj, pl, callerIsMethod);
              
            elseif pl.isparam_core('tsfcn')
              
              %-----------------------------------------------------
              %--- Construct from Time-series function
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from fcn(t) %s', pl.find_core('tsfcn'));
              obj = fromTSfcn(obj, pl);
              
            elseif pl.isparam_core('xyfcn')
              
              %-----------------------------------------------------
              %--- Construct from XY function
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from fcn(x) %s', pl.find_core('xyfcn'));
              obj = obj.fromXYFcn(pl);
              
            elseif pl.isparam_core('fsfcn')
              
              %-----------------------------------------------------
              %--- Construct from frequency-series function
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from fcn(f) %s', pl.find_core('fsfcn'));
              obj = obj.fromFSfcn(pl);
              
            elseif pl.isparam_core('win')
              
              %-----------------------------------------------------
              %--- Construct from Window
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from window %s', char(pl.find_core('win')));
              obj = obj.fromSpecWin(pl);
              
            elseif pl.isparam_core('waveform')
              
              %-----------------------------------------------------
              %--- Construct from Waveform
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from waveform %s', pl.find_core('waveform'));
              obj = fromWaveform(obj, pl, callerIsMethod);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn') || pl.isparam_core('id')
              
              %-----------------------------------------------------
              %--- Construct from repository
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('polyval')
              
              %-----------------------------------------------------
              %--- Construct from polynomial
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from polynomial ');
              obj = obj.fromPolyval(pl);
              
            elseif pl.isparam_core('pzmodel')
              
              %-----------------------------------------------------
              %--- Construct from pzmodel
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from pzmodel %s', char(pl.find_core('pzmodel')));
              obj = obj.fromPzmodel(pl);
              
            elseif pl.isparam_core('model')
              
              %-----------------------------------------------------
              %--- Construct from smodel
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from symbolic model %s', char(pl.find_core('smodel')));
              obj = obj.fromSModel(pl, callerIsMethod);
              
            elseif pl.isparam_core('Pest')
              
              %-----------------------------------------------------
              %--- Construct from pest
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from pest object %s', char(pl.find_core('pest')));
              obj = obj.fromPest(pl);
              
              
            elseif pl.isparam_core('parameter')
              
              utils.helper.msg(msg.PROC2, 'constructing from parameter');
              obj = obj.fromParameter(pl);
              
            else
              % build a no-data ao from the plist and default values
              pl = applyDefaults(ao.getDefaultPlist('Default') , pl);
              obj.setObjectProperties(pl);
              obj.addHistory(ao.getInfo('ao', 'None'), pl, [], []);
            end
            
          elseif isa(args{1}, 'specwin')
            %%%%%%%%%%   a1 = ao(specwin)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from spectral window %s', char(args{1}));
            obj = obj.fromSpecWin(plist('win', args{1}));
            
          elseif isa(args{1}, 'smodel')
            %%%%%%%%%%   a1 = ao(smodel)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from smodel %s', char(args{1}));
            obj = obj.fromSModel(plist('model', args{1}), callerIsMethod);
            
          elseif isa(args{1}, 'pest')
            %%%%%%%%%%   a1 = ao(pest)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from pest %s', char(args{1}));
            obj = obj.fromPest(plist('pest', args{1}));
            
          elseif isa(args{1}, 'ltpda_data')
            %%%%%%%%%%   a1 = ao(ltpda_data-object)   %%%%%%%%%%
            %%%%%%%%%%   a1 = ao(cdata)               %%%%%%%%%%
            %%%%%%%%%%   a1 = ao(fsdata)              %%%%%%%%%%
            %%%%%%%%%%   a1 = ao(tsdata)              %%%%%%%%%%
            %%%%%%%%%%   a1 = ao(xydata)              %%%%%%%%%%
            %%%%%%%%%%   a1 = ao(xyzdata)             %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from data object %s', class(args{1}));
            obj.data        = args{1};
            if ~callerIsMethod
              obj.addHistory(ao.getInfo('ao', 'None'), [], [], []);
            end
          elseif islogical(args{1})
            %%%%%%%%%%% a1 = ao(true)    %%%%%%%%%%%%%
            utils.helper.msg(msg.PROC3, 'constructing from logical');
            obj = fromVals(obj, plist('VALS', args{1}), callerIsMethod);
            
          else
            error('### Unknown single input constructor');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two inputs   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')
            %%%%%%%%%%   ao(database-object, [IDs])   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from database object');
            pl = plist('conn', varargin{1}, 'id', varargin{2});
            obj = obj.fromRepository(pl);
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   ao('dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isnumeric(args{1}) && ischar(args{2})
            %%%%%%%%%%   ao(<double>, yunits)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from constant values and yunits');
            obj = obj.fromVals(plist('VALS', args{1}, 'yunits', args{2}), callerIsMethod);
            
          elseif isnumeric(args{1}) && isnumeric(args{2}) && numel(args{1}) == numel(args{2})
            %%%%%%%%%%   ao(x-vector, y-vector)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from X and Y values');
            obj = obj.fromXYVals(plist('XVALS', args{1}, 'YVALS', args{2}), callerIsMethod);
            
          elseif isnumeric(args{1}) && isnumeric(args{2}) && numel(args{2}) == 1
            %%%%%%%%%%   ao(y-vector, fs)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from Y values and fs');
            obj = obj.fromXYVals(plist('YVALS', args{1}, 'fs', args{2}, 'xunits', unit.seconds), callerIsMethod);
            
          elseif isa(args{1}, 'pzmodel') && isa(args{2}, 'plist')
            %%%%%%%%%%  f = ao(pzmodel-object, plist-object)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from pzmodel %s', args{1}.name);
            obj = obj.fromPzmodel(combine(plist('pzmodel', args{1}), args{2}));
            
          elseif isnumeric(args{1}) && isa(args{2}, 'plist')
            %%%%%%%%%%   ao(<double>, pl)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from constant values and plist');
            obj = obj.fromVals(combine(plist('VALS', args{1}), args{2}), callerIsMethod);
            
          elseif ischar(args{1}) && isa(args{2}, 'plist')
            %%%%%%%%%%%   ao('foo.txt', pl)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from filename and plist');
            pl = combine(plist('filename', args{1}), args{2});
            obj = obj.fromFile(pl);
            
          elseif isa(args{1}, 'ao') && isa(args{2}, 'ao')
            %%%%%%%%%%%   ao(ao-object, ao-object)   %%%%%%%%%%
            % Do we have a list of AOs as input
            obj = ao([args{1}, args{2}]);
            
          elseif isa(args{1}, 'ao') && isa(args{2}, 'plist') && isempty(varargin{2}.params)
            %%%%%%%%%%  f = ao(ao-object, <empty plist>) %%%%%%%%%%
            obj = ao(varargin{1});
            
          elseif isa(args{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(args{2}, 'history')
            %%%%%%%%%%   obj = ao(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, args{1}, args{2});
            
          elseif isa(args{1}, 'ltpda_uoh') && isa(args{2}, 'plist')
            %%%%%%%%%%%   ao(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if args{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(args{2}, 'filename')), 'file')==2
                obj = ao(args{2});
              else
                obj = ao(args{1});
              end
            else
              obj = ao(args{2});
            end
          else
            error('### Unknown constructor with two inputs.\n### The arguments are from type ''%s'' [%dx%d] and ''%s'' [%dx%d]', class(args{1}), size(args{1}), class(args{2}), size(args{2}));
          end
          
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   three inputs   %%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if  isnumeric(args{1}) && isnumeric(args{2}) && isnumeric(args{3}) && ...
              numel(args{1}) == numel(args{2}) && numel(args{3}) == 1
            %%%%%%%%%%   ao(x-vector, y-vector, fs)   %%%%%%%%%%
            
            utils.helper.msg(msg.PROC1, 'constructing from X and Y values and frequency.');
            obj = obj.fromXYVals(plist('XVALS', args{1}, 'YVALS', args{2}, 'FS', args{3}), callerIsMethod);
            
          elseif iscellstr(varargin)
            %%%%%%%%%%   ao('from', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          elseif isnumeric(args{1}) && isnumeric(args{2}) && isa(args{3}, 'plist')
            %%%%%%%%%%   ao(x-vector, y-vector, plist)   %%%%%%%%%%
            
            utils.helper.msg(msg.PROC1, 'constructing from X and Y values and frequencies.');
            pl = combine(plist('XVALS', args{1}, 'YVALS', args{2}), args{3});
            obj = obj.fromXYVals(pl, callerIsMethod);
            
          elseif isa(args{1}, 'pzmodel') && isnumeric(args{2}) && isnumeric(args{3})
            %%%%%%%%%%   ao(pzmodel, nsecs, fs)   %%%%%%%%%%
            
            utils.helper.msg(msg.PROC2, 'constructing from pzmodel %s', char(args{1}));
            pl = plist('pzmodel', args{1}, 'Nsecs', args{2}, 'fs', args{3});
            obj = obj.fromPzmodel(pl);
            
          else
            
            [aoi, ~, rest] = utils.helper.collect_objects(args, 'ao');
            
            %%% Do we have a list of AOs as input
            if ~isempty(aoi) && isempty(rest)
              obj = ao(aoi);
            else
              error('### Unknown constructor with three inputs.\n1. Argument: %s [%dx%d]\n2. Argument: %s [%dx%d]\n3. Argument: %s [%dx%d]', class(args{1}), size(args{1}), class(args{2}), size(args{2}), class(args{3}), size(args{3}));
            end
          end
          
        otherwise
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   other inputs   %%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   ao('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [aoi, ~, rest] = utils.helper.collect_objects(args, 'ao');
            
            %%% Do we have a list of AOs as input
            if ~isempty(aoi) && isempty(rest)
              obj = ao(aoi);
            else
              error('### Unknown number of arguments.');
            end
          end
      end
      
      % handle any split keys which have been passed. Currently we
      % only support 'timespan'.
      if ~isempty(pli) && pli.isparam_core('timespan') && ~isempty(pli.find_core('timespan'))
        % but we may have more than one object here, so apply split() to
        % each one.
        for oo=1:numel(obj)
          if isa(obj(oo).data, 'tsdata')
            name = obj(oo).name;
            obj(oo) = obj(oo).split(pli.subset('timespan'));
            obj(oo).name = name;
          else
            warning('You specified a timespan but this cannot be used to split a %s AO', class(obj.data));
          end
        end
      end
      
    end % End constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (public)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    
    % Setters
    varargout = setXunits(varargin)
    varargout = setYunits(varargin)
    varargout = setT0(varargin)
    varargout = setFs(varargin)
    varargout = setXY(varargin)
    varargout = setY(varargin)
    varargout = setX(varargin)
    varargout = setZ(varargin)
    varargout = setDy(varargin)
    varargout = setDx(varargin)
    
    % Other methods
    varargout = copy(varargin)
    h   = md5(varargin)
    val = fromProcinfo(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    varargout = setData(varargin)
    varargout = ifft_core(varargin)
    varargout = fft_core(varargin)
    varargout = fftfilt_core(varargin)
    varargout = xspec(varargin)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
    varargout = performFFTcore(varargin)
    varargout = lsf(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (public, static)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true)
    
    function out = c(varargin)
      % C convenient constructor of an AO containing the value of the speed of light in vacuum.
      %
      % CALL:
      %        c = ao.c()
      %        c = ao.c
      %
      name = 'c';
      out = ao(plist('parameter', 'physical_constants', 'key', name));
    end
    
    function out = G(varargin)
      % G convenient constructor of an AO containing the value of the universal constant of gravitation.
      %
      % CALL:
      %        G = ao.G()
      %        G = ao.G
      %
      name = 'G';
      out = ao(plist('parameter', 'physical_constants', 'key', name));
    end
    
    function out = h(varargin)
      % H convenient constructor of an AO containing the value of the Planck constant.
      %
      % CALL:
      %        h = ao.h()
      %        h = ao.h
      %
      name = 'h';
      out = ao(plist('parameter', 'physical_constants', 'key', name));
    end
    
    function out = e(varargin)
      % e convenient constructor of an AO containing the value of the elementary charge.
      %
      % CALL:
      %        e = ao.e()
      %        e = ao.e
      %
      name = 'e';
      out = ao(plist('parameter', 'physical_constants', 'key', name));
    end
    
    function out = kB(varargin)
      % kB convenient constructor of an AO containing the value of the Boltzmann's constant.
      %
      % CALL:
      %        kB = ao.kB()
      %        kB = ao.kB
      %
      name = 'kB';
      out = ao(plist('parameter', 'physical_constants', 'key', name));
    end
    
    function out = mu0(varargin)
      % mu0 convenient constructor of an AO containing the value of the vacuum permeability.
      %
      % CALL:
      %        mu0 = ao.mu0()
      %        mu0 = ao.mu0
      %
      name = 'mu0';
      out = ao(plist('parameter', 'physical_constants', 'key', name));
    end
    
    function out = epsilon0(varargin)
      % epsilon0 convenient constructor of an AO containing the value of the vacuum permittivity.
      %
      % CALL:
      %        e0 = ao.epsilon0()
      %        e0 = ao.epsilon0
      %
      name = 'epsilon0';
      out = ao(plist('parameter', 'physical_constants', 'key', name));
    end
    
    function out = R(varargin)
      % R convenient constructor of an AO containing the value of the gas constant.
      %
      % CALL:
      %        R = ao.R()
      %        R = ao.R
      %
      name = 'R';
      out = ao(plist('parameter', 'physical_constants', 'key', name));
    end
    
    function n = ones(varargin)
      % ONES convenient constructor of an AO containing ones.
      %
      % CALL:
      %        n = ao.ones(nsamples)  % cdata AO
      %        n = ao.ones(nsecs, fs) % tsdata AO
      %
      switch nargin
        case 1
          % cdata(nsamples)
          n = ao(plist('vals', ones(varargin{1},1)));
        case 2
          n = ao(plist('tsfcn', 'ones(size(t))', 'fs', varargin{2}, 'nsecs', varargin{1}));
        otherwise
          error('Unknown input arguments');
      end
    end
    
    function n = zeros(varargin)
      % ZEROS convenient constructor of an AO containing zeros.
      %
      % CALL:
      %        n = ao.zeros(nsamples)  % cdata AO
      %        n = ao.zeros(nsecs, fs) % tsdata AO
      %
      switch nargin
        case 1
          % cdata(nsamples)
          n = ao(plist('vals', zeros(varargin{1},1)));
        case 2
          n = ao(plist('tsfcn', 'zeros(size(t))', 'fs', varargin{2}, 'nsecs', varargin{1}));
        otherwise
          error('Unknown input arguments');
      end
    end
    
    function n = randn(varargin)
      % RANDN convenient constructor of an AO containing random numbers.
      %
      % CALL:
      %        n = ao.randn(nsamples)  % cdata AO
      %        n = ao.randn(nsecs, fs) % tsdata AO
      %
      switch nargin
        case 1
          % cdata(nsamples)
          n = ao(plist('vals', randn(varargin{1},1)));
        case 2
          n = ao(plist('tsfcn', 'randn(size(t))', 'fs', varargin{2}, 'nsecs', varargin{1}));
        otherwise
          error('Unknown input arguments');
      end
      
      
    end
    
    function n = sinewave(varargin)
      % SINEWAVE convenient constructor of an AO containing a sine wave.
      %
      % CALL:
      %        n = ao.sinewave(nsecs, fs, f0, phi)  % tsdata AO
      %
      switch nargin
        case 4
          n = ao(plist('waveform', 'sine wave', ...
            'f', varargin{3}, 'phi', varargin{4}, ...
            'fs', varargin{2}, 'nsecs', varargin{1}));
        otherwise
          error('Unknown input arguments');
      end
    end
    
    function varargout = getBuiltInModels(varargin)
      if nargout == 0
        ltpda_uo.getBuiltInModels(mfilename('class'));
      else
        varargout{1} = ltpda_uo.getBuiltInModels(mfilename('class'));
      end
    end
    
    function out = SETS()
      out = [SETS@ltpda_uoh,                ...
        {'From MAT Data File'},             ...
        {'From ASCII File'},                ...
        {'From Complex ASCII File'},        ...
        {'From Function'},                  ...
        {'From Values'},                    ...
        {'From XY Values'},                 ...
        {'From XYZ Values'},                ...
        {'From Time-series Function'},      ...
        {'From XY Function'},               ...
        {'From Frequency-series Function'}, ...
        {'From Window'},                    ...
        {'From Waveform'},                  ...
        {'From Polynomial'},                ...
        {'From Pzmodel'},                   ...
        {'From Smodel'},                    ...
        {'From Pest'},                       ...
        {'From Parameter'}                  ...
        ];
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, mfilename('class'));
    end
    
    % Return the plist for a particular parameter set
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
        pl = ao.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function objs = initObjectWithSize(varargin)
      objs = ao.newarray([varargin{:}]);
      for ii = 1:numel(objs)
        obj = objs(ii);
        addlistener(obj, 'timespan', 'PreGet', @obj.getPropEvt);
      end
    end
    
    varargout = diff2p_core(varargin)
    varargout = diff3p_core(varargin)
    varargout = diff5p_core(varargin)
    varargout = fft_1sided_core(varargin)
    varargout = fft_2sided_core(varargin)
    varargout = ifft_1sided_odd_core(varargin)
    varargout = ifft_1sided_even_core(varargin)
    varargout = ifft_2sided_core(varargin)
    varargout = ifft_plain_core(varargin)
    varargout = split_samples_core(varargin)
    varargout = zeropad_post_core(varargin)
    varargout = delay_fractional_core(varargin)
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (protected)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    obj = fromDataInMAT(obj, data, filename)
    obj = fromDatafile(obj, pli)
    obj = fromComplexDatafile(obj, pli)
    obj = fromStruct(obj, a_struct)
    varargout = csvGenerateData(varargin)
    varargout = checkDataType(varargin)
    varargout = checkNumericDataTypes(varargin)
    varargout = processSetterValues(varargin)
    
    function getPropEvt(obj,src,evnt)
      if ~isempty(obj.data)
        % Get the timespan from the data object.
        ts = obj.data.getTimespan;
        if ~isempty(ts)
          obj.timespan = ts;
        end
      end
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (protected, static)                       %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    
    function pl = addGlobalKeys(pl)
      % Call super-class
      addGlobalKeys@ltpda_uoh(pl);
      
      % Yunits
      pl.append({'yunits','Unit on Y axis'}, paramValue.EMPTY_DOUBLE);
      
    end
    
    function pl = removeGlobalKeys(pl)
      % Call super-class
      removeGlobalKeys@ltpda_uoh(pl);
    end
    
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(ao.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = buildplist@ltpda_uoh(out, set);
      
      % Otherwise we try to find a set for this constructor
      switch lower(set)
        case 'from mat data file'
          % filename
          p = param({'filename','MAT data filename.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % filepath
          p = param({'filepath','Path to the data file in case the filename is a relative path.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % type
          p = param({'type','Choose the data type.'},  paramValue.DATA_TYPES);
          out.append(p);
          
          % columns
          p = param({'columns', ['Specify column pairs for the <tt>x-y</tt> variables, e.g. [1 2 1 4].<br>',...
            'Each column pair creates an analysis object.<br>',...
            'If the value ''fs'' is set then each column represents only the <tt>y</tt>-axes.<br>']}, ...
            {1, {[]}, paramValue.OPTIONAL});
          out.append(p);
          
          % Xunits
          p = param({'xunits','Unit on X axis.'},  unit.seconds);
          out.append(p);
          
          % Fs
          p = param({'fs','If this value is set, the x-axes is computed from the fs value.'},  paramValue.EMPTY_DOUBLE);
          out.append(p);
          
        case 'from ascii file'
          
          % filename
          p = param({'filename','ASCII filename.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % filepath
          p = param({'filepath','Path to the data file in case the filename is a relative path.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % type
          p = param({'type','Choose the data type.'},  paramValue.DATA_TYPES);
          out.append(p);
          
          % columns
          p = param({'columns', ['Specify column pairs for the <tt>x-y</tt> variables, e.g. [1 2 1 4].<br>',...
            'Each column pair creates an analysis object.<br>',...
            'If the value ''fs'' is set then each column represents only the <tt>y</tt>-axes.<br>']}, ...
            {1, {[]}, paramValue.OPTIONAL});
          out.append(p);
          
          % Xunits
          p = param({'xunits','Unit on X axis.'},  paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Comment char
          p = param({'comment_char','The comment character in the file.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Maximum number of lines
          p = param({'maxlines', 'Maximum number of lines which should be read.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Fs
          p = param({'fs','If this value is set, the x-axes is computed from the fs value.'},  paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Delimiter
          p = param({'Delimiter', 'Field delimiter character(s).'},   paramValue.STRING_VALUE(''));
          out.append(p);
          
          % T0
          p = param({'T0', ['The UTC time of the first sample.<br>' ...
            'For data types other than tsdata, this is ignored.']}, {1, {'1970-01-01 00:00:00.000 UTC'}, paramValue.OPTIONAL});
          out.append(p);
          
          % IgnoreLines
          p = param({'ignoreLines', 'Ignore the first few lines. Reading numeric data starting from line IgnoreLines + 1.'}, paramValue.DOUBLE_VALUE(0));
          out.append(p);
          
          % HeaderLines
          p = param({'HeaderLines', 'Use the first N lines for the description. Reading numeric data starting from line HeaderLines + 1.'}, paramValue.DOUBLE_VALUE(0));
          out.append(p);
          
          % Robust
          p = param({'Robust',['Set this to ''true'' to use (slow) data reading.<br>',...
            'All values must be numbers and separated by blanks.']},   paramValue.TRUE_FALSE);
          p.val.setValIndex(2);
          out.append(p);
          
          
          %------------------------------------------
          %--- Read from complex ASCII file
          %------------------------------------------
        case 'from complex ascii file'
          
          % Filename
          p = param({'filename','ASCII filename.'},  paramValue.EMPTY_STRING);
          out.append(p);
          
          % filepath
          p = param({'filepath','Path to the data file in case the filename is a relative path.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % Complex type
          p = param({'complex_type','String defining the format of the complex data.'}, ...
            {1, {'real/imag', 'abs/deg', 'dB/deg', 'abs/rad', 'dB/rad'}, paramValue.SINGLE});
          out.append(p);
          
          % Type
          p = param({'type','String defining the data type'},  paramValue.DATA_TYPES);
          p.val.setValIndex(2);
          out.append(p);
          
          % columns
          p = param({'columns',['Colums to consider inside the file. <br>',...
            'It must be 3 or a multiple: the first column defines the x-axis and the next <br>',...
            'two columns the complex y-axis. If a multiple of 3 columns are specified, <br>',...
            'the constructor will output multiple aos. (e.g. [1 2 3])']}, ...
            {1, {[1 2 3]}, paramValue.OPTIONAL});
          out.append(p);
          
          % Xunits
          p = param({'xunits','Unit on X axis.'},  unit.Hz);
          out.append(p);
          
          % Comment char
          p = param({'comment_char','The comment character in the file.'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % T0
          p = param({'T0', ['The UTC time of the first sample.<br>' ...
            'For data types other than tsdata, this is ignored.']}, {1, {'1970-01-01 00:00:00.000 UTC'}, paramValue.OPTIONAL});
          out.append(p);
          
          %------------------------------------------
          %--- Create from a function description
          %------------------------------------------
        case 'from function'
          
          % Fcn
          p = param({'fcn','Any valid MATLAB function. [e.g. ''randn(100,1)'']'}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % dy
          p = param({'dy','A set of errors values for y.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % RAND_STREAM
          out.append(copy(plist.RAND_STREAM, 1));
          
          %------------------------------------------
          %--- Create from a set of values
          %------------------------------------------
        case 'from values'
          
          % Vals
          p = param({'vals','A set of values.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % dy
          p = param({'dy','A set of errors values for y.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % axis
          p = param({'axis','If an AO is input in ''vals'', this key specifies which axis we get the data from.'}, {2, {'x', 'y', 'z'}, paramValue.SINGLE});
          out.append(p);
          
          % N
          p = param({'N','Repeat ''N'' times.'},   {1, {1}, paramValue.OPTIONAL});
          out.append(p);
          
          %------------------------------------------
          %--- Create from a set of values
          %------------------------------------------
        case 'from xy values'
          
          % Type
          p = param({'type','The data type.'}, {1, {'', 'tsdata', 'fsdata', 'xydata', 'cdata'}, paramValue.SINGLE});
          out.append(p);
          
          % Fs
          p = param({'fs',['Frequency: if this is set, xvals (if passed) will be ignored and the <br>',...
            'resulting tsdata will contain an X vector sampled according to fs. <br>', ...
            'For data types other than tsdata, this is ignored.']}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % T0
          p = param({'T0', ['The time of the first sample.<br>' ...
            'For data types other than tsdata, this is ignored.']}, {1, {'1970-01-01 00:00:00.000 UTC'}, paramValue.OPTIONAL});
          out.append(p);
          
          % toffset
          p = param({'toffset', ['The offset between the first x sample and t0.<br>' ...
            'For data types other than tsdata, this is ignored.']}, paramValue.DOUBLE_VALUE(0));
          out.append(p);
          
          % Xvals
          p = param({'xvals','A set of x values.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Yvals
          p = param({'yvals','A set of y values.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % dx
          p = param({'dx','A set of errors values for x.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % dy
          p = param({'dy','A set of errors values for y.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Xunits
          p = param({'xunits','Unit on X axis.'},  paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          %------------------------------------------
          %--- Create from a set of x, y and z values
          %------------------------------------------
        case 'from xyz values'
          
          % Xvals
          p = param({'xvals','A set of x values.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Yvals
          p = param({'yvals','A set of y values.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Zvals
          p = param({'zvals','A set of z values.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % z-axis
          p = param({'zaxis','Indicate which axis/field to take the values from to populate the z data.'}, {3, {'x', 'y', 'z'}, paramValue.SINGLE});
          out.append(p);
          
          % dx
          p = param({'dx','A set of errors values for x.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % dy
          p = param({'dy','A set of errors values for y.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % dz
          p = param({'dz','A set of errors values for z.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Xunits
          p = param({'xunits','Unit on X axis.'},  paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Zunits
          p = param({'zunits','Unit on Z axis'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          %------------------------------------------
          %--- Create from a XY function
          %------------------------------------------
        case 'from xy function'
          
          % XY fcn
          p = param({'xyfcn','Specify a function of x. (e.g. x.^2)'},  {1, {'x'}, paramValue.OPTIONAL});
          out.append(p);
          
          % X
          p = param({'X','The x values.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Xunits
          p = param({'xunits','Unit on X axis.'},  paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % dx
          p = param({'dx','A set of errors values for x.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % dy
          p = param({'dy','A set of errors values for y.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % RAND_STREAM
          out.append(copy(plist.RAND_STREAM, 1));
          
          %------------------------------------------
          %--- Create from a time-series function
          %------------------------------------------
        case 'from time-series function'
          
          % TS fcn
          p = param({'tsfcn','A function of time.'},   {1, {'t'}, paramValue.OPTIONAL});
          out.append(p);
          
          % Fs, Nsecs, Xunits
          out.append(plist.TSDATA_PLIST);
          
          % dy
          p = param({'dy','A set of errors values for y.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % RAND_STREAM
          out.append(copy(plist.RAND_STREAM, 1));
          
          %------------------------------------------
          %--- Create from frequency-series function
          %------------------------------------------
        case 'from frequency-series function'
          
          % FS fcn
          p = param({'fsfcn','A function of frequency.'}, {1, {'f'}, paramValue.OPTIONAL});
          out.append(p);
          
          % F1
          p = param({'f1','The initial frequency.'},  {1, {1e-9}, paramValue.OPTIONAL});
          out.append(p);
          
          % F2
          p = param({'f2','The final frequency.'},  {1, {10000}, paramValue.OPTIONAL});
          out.append(p);
          
          % Nf
          p = param({'nf','The number of frequency samples.'}, {1, {1000}, paramValue.OPTIONAL});
          out.append(p);
          
          % Scale
          p = param({'scale','Choose the frequency spacing.'}, {2, {'lin', 'log'}, paramValue.SINGLE});
          out.append(p);
          
          % F
          p = param({'f','a vector of frequencies on which to evaluate the function.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % dy
          p = param({'dy','A set of errors values for y.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Xunits
          p = param({'xunits','Unit on X axis.'},  unit.Hz);
          out.append(p);
          
          % RAND_STREAM
          out.append(copy(plist.RAND_STREAM, 1));
          
          %------------------------------------------
          %--- Create from a window function
          %------------------------------------------
        case 'from window'
          % Win
          p = param({'win','A Spectral window name.'},  paramValue.WINDOW);
          out.append(p);
          
          % length
          p = param({'length','The length of the window (number of samples).'},  paramValue.DOUBLE_VALUE(100));
          out.append(p);
          
          % psll
          p = param({'psll','If you choose a ''kaiser'' window, you can also specify the peak-sidelobe-level.'},  paramValue.DOUBLE_VALUE(150));
          out.append(p);
          
          % level order
          p = param({'levelOrder','If you choose a ''levelledHanning'' window, you can also specify the order of the contraction.'},  paramValue.DOUBLE_VALUE(2));
          out.append(p);
          
          %------------------------------------------
          %--- Create from a set of polynomial coefficients
          %------------------------------------------
        case 'from polynomial'
          
          % Polyval
          p = param({'polyval',['A set of polynomial coefficients. This can also be an AO, <br>',...
            'in which case the Y values from the AO are used.']}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Fs
          p = param({'fs', 'The sampling frequency of the signal. [for all]'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Nsecs
          p = param({'nsecs', 'The number of seconds of data. [for all]'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % T0
          p = param({'T0', 'The UTC time of the first sample. [for all]'}, {1, {'1970-01-01 00:00:00.000 UTC'}, paramValue.OPTIONAL});
          out.append(p);
          
          % toffset
          p = param({'toffset', 'The offset between the first x sample and t0.'}, paramValue.DOUBLE_VALUE(0));
          out.append(p);
          
          % T
          p = param({'t',['Vector of time vertices for tsdata type. <br>',...
            'The value can also be an AO, in which case the X vector is used.']}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % X
          p = param({'x', 'Vector of X values for xydata type. <br>',...
            'The value can also be an AO, in which case the X vector is used.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % F
          p = param({'f', 'Vector of frequency values for fsdata type. <br>',...
            'The value can also be an AO, in which case the X vector is used.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Type
          p = param({'type','The data type. If this is empty, the constructor will attempt to determine the type from the other parameters.'}, {1,{'', 'tsdata', 'fsdata', 'xydata', 'cdata'}, paramValue.SINGLE});
          out.append(p);
          
          % Xunits
          p = param({'xunits','Unit on X axis.'},  paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          %------------------------------------------
          %--- Create from a waveform description
          %------------------------------------------
        case 'from waveform'
          % Waveform
          p = param({'waveform', 'A waveform description.<br>A special case is the ''<b>sine wave</b>'' because you can create more sinewaves which are summed. For this case you can add several values for ''A'', ''f'', ''phi'', ''nsecs'' and/or ''Toff'''}, ...
            {1, {'sine wave', 'noise', 'chirp', 'gaussian pulse', 'square wave', 'sawtooth'}, paramValue.OPTIONAL});
          out.append(p);
          
          % A
          p = param({'A','Amplitude of the signal. [for ''sine wave''].'}, {1, {1}, paramValue.OPTIONAL});
          out.append(p);
          
          % F
          p = param({'f', 'Frequency of the signal, in Hz. [for ''sine wave'', ''square wave'', ''sawtooth''].'}, ...
            {1, {1}, paramValue.OPTIONAL});
          out.append(p);
          
          % Phi
          p = param({'phi', ['Phase of the signal, in rad. [for ''sine wave'']<br>' ...
            'The phase is lag, i.e. y = sin(2*pi*f*t + phi)']}, {1, {0}, paramValue.OPTIONAL});
          out.append(p);
          
          % Toff
          p = param({'Toff', ['Offset of the different sine waves, as [for ''sine wave'']<ul>', ...
            '<li>a vector of seconds</li>', ...
            '<li>a cell array with the offsets as a string</li>', ...
            '<li>a vector time objects</li>', ...
            '</ul>Remark: If t0 is not specified then it will be set to the first value of Toff.<br><br>Offset of the signal, in seconds.  [for all other]']}, {1, {0}, paramValue.OPTIONAL});
          out.append(p);
          
          % gaps
          p = param({'gaps', 'Instead of defining an offset it is possible to define a gap before the sine wave. [for ''sine wave'']<br/>'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Type
          p = param({'Type', 'Noise type. [for ''noise'']'}, {1, {'Normal', 'Uniform'}, paramValue.SINGLE});
          out.append(p);
          
          % Sigma
          p = param({'Sigma', 'The standard deviation of the noise. [for ''noise'']'}, {1, {1}, paramValue.OPTIONAL});
          out.append(p);
          
          % F0
          p = param({'F0', 'A fundamental/start frequency of the signal. [for ''chirp'', ''gaussian pulse'']'}, ...
            {1, {1}, paramValue.OPTIONAL});
          out.append(p);
          
          % F1
          p = param({'F1', 'The end frequency of the signal. [for ''chirp'']'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % T1
          p = param({'T1', 'The end time of the signal. [for ''chirp'']'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % BW
          p = param({'BW', 'The bandwidth of the signal. [for ''gaussian pulse'']'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Duty
          p = param({'Duty', 'The duty-cycle of the signal (in %). [for ''square wave'']'}, {1, {50}, paramValue.OPTIONAL});
          out.append(p);
          
          % Width
          p = param({'Width', 'The width of the signal. [0-1] [for ''sawtooth'']'}, {1, {0.5}, paramValue.OPTIONAL});
          out.append(p);
          
          % Offset
          p = param({'Offset','Offset to be added to the signal.'}, {1, {0}, paramValue.OPTIONAL});
          out.append(p);
          
          % Fs, Nsecs, Xunits
          out.append(plist.TSDATA_PLIST);
          
          % RAND_STREAM
          out.append(copy(plist.RAND_STREAM, 1));
          
          %------------------------------------------
          %--- Create from a set of pzm coefficients
          %------------------------------------------
        case 'from pzmodel'
          
          % PZModel
          p = param({'pzmodel','A pole/zero model which builds the time-series AO.'}, {1, {pzmodel}, paramValue.OPTIONAL});
          out.append(p);
          
          % ndigits
          p = param({'ndigits','Set the number of digits of precision to be used when calculating the noise generation coefficients.'}, paramValue.DOUBLE_VALUE(32));
          out.append(p);
          
          % Fs, Nsecs, Xunits
          out.append(plist.TSDATA_PLIST);
                    
          % Initial state vector
          p = param({'state','Initial state vector. If empty, and initial state will be calculated. The final state of a noise generation will be stored in the procinfo of the resulting AO.'},  paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % RAND_STREAM
          out.append(copy(plist.RAND_STREAM, 1));
          
          %------------------------------------------
          %--- Create from a smodel
          %------------------------------------------
        case 'from smodel'
          
          % Model
          p = param({'model', 'The smodel to evaluate and convert to an AO. '}, {1, {smodel()}, paramValue.OPTIONAL});
          out.append(p);
          
          % X
          p = param({'x','Values for X axis.'},  paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Xunits
          p = param({'xunits','Unit on X axis.'},  unit.seconds);
          out.append(p);
          
          % Type
          p = param({'type','Choose the data type.'},  paramValue.DATA_TYPES);
          p.val.setValIndex(1);
          out.append(p);
          
          % RAND_STREAM
          out.append(copy(plist.RAND_STREAM, 1));
          
          %------------------------------------------
          %--- Create from a pest
          %------------------------------------------
        case 'from pest'
          
          % Model
          p = param({'pest', 'The pest object to extract the AO from. '}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
          % Parameter
          p = param({'parameter',['Name of the parameter(s) to be extracted.<br>' ...
            'If empty, all parameters will be extracted into a vector ao AOs.']},  paramValue.STRING_VALUE(''));
          out.append(p);
          
          % RAND_STREAM
          out.append(copy(plist.RAND_STREAM, 1));
          
        case 'from parameter'
          
          % parameter
          p = param({'parameter', ['The parameter or plist to make an AO from. <br>' ...
            'If the plist is a built-in one, it is also possible just to input its name.']}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % key
          p = param({'key', 'The parameter name to extract from the plist. '}, paramValue.EMPTY_STRING);
          out.append(p);
          
          % RAND_STREAM
          out.append(copy(plist.RAND_STREAM, 1));
          
      end
      
      % Add the global keys
      out = ao.addGlobalKeys(out);
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Methods (private)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    % Constructors
    varargout = fromParameter(varargin)
    varargout = fromVals(varargin)
    varargout = fromXYVals(varargin)
    varargout = fromXYZVals(varargin)
    varargout = fromTSfcn(varargin)
    varargout = fromWaveform(varargin)
    varargout = fromFcn(varargin)
    varargout = fromFSfcn(varargin)
    varargout = fromSpecWin(varargin)
    varargout = fromPolyval(varargin)
    varargout = fromSModel(varargin)
    varargout = fromPzmodel(varargin)
    varargout = fromXYFcn(varargin)
    varargout = fromPest(varargin)
    
    % Content modifiers
    varargout = fixAxisData(varargin)
    varargout = smallvec_coef(in,pl)
    
    varargout = setUnitsForAxis(varargin)
    varargout = clearErrors(varargin)
    
    % Others
    varargout = applyoperator(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
    % constructor functions
    % Spectral estimate function
    varargout = wosa(varargin);
    [P,f] = computeperiodogram(x,win,nfft,esttype,varargin)
    [Xx,f] = computeDFT(xin,nfft,varargin)
    
    % Noise generator functions
    varargout = ngconv(varargin)
    varargout = ngsetup(varargin)
    varargout = ngsetup_vpa(varargin)
    varargout = nginit(varargin)
    varargout = ngprop(varargin)
    varargout = fq2fac(varargin)
    varargout = conv_noisegen(varargin)
    varargout = mchol(varargin)
    
    % LPSD-type methods
    varargout = ltf_plan(varargin)
    varargout = mlpsd_mex(varargin)
    varargout = mlpsd_m(varargin)
    varargout = mltfe(varargin)
    varargout = findFsMax(varargin)
    varargout = findFsMin(varargin)
    varargout = findShortestVector(varargin)
    varargout = lxspec(varargin)
    
    varargout = ltpda_fitChiSquare(varargin)
    
    varargout = elementOp(varargin)
    varargout = melementOp(varargin)
    
    varargout = applymethod(varargin)
    
  end
  
end
