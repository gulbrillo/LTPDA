% LTPDA_ALGORITHM is a superclass for algorithm classes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LTPDA_ALGORITHM is a superclass for algorithm classes. It
%              provides functionality for handling input plists and for
%              adding history steps.
%
% SUPER CLASSES: ltpda_uoh
%
% SUB CLASSES:   MCMC
%
% LTPDA_ALGORITHM PROPERTIES:
%
%     Protected Properties (read only)
%       package  -
%       category -
%       params   -
%
% SEE ALSO: ltpda_uoh, MCMC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) ltpda_algorithm < ltpda_uoh
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  properties
    package  = '';
    category = '';
    params   = [];
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    
    function obj = ltpda_algorithm(name, package, category, description, varargin)
      
      import utils.const.*
      utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
      
      % Gather inputs
      [pls, ~, args] = utils.helper.collect_objects(varargin(:), 'plist');
      
      % Collect all plists
      if numel(pls)
        % Combine if multiple plists
        if numel(pls)>1
          pls = pls.combine();
        else
          pls = copy(pls, 1);
        end
        % Append the plist to the input-arguments
        args{end+1} = pls;
      end
      
      % Set properties
      obj.name        = name;
      obj.description = description;
      obj.package     = package;
      obj.category    = category;
      
      % Execute appropriate constructor
      switch numel(args)
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          obj.params = copy(obj.getDefaultPlist('default'), 1);
          obj.finalise();
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(args{1}) || iscell(args{1})
            %%%%%%%%%%   m = ltpda_algorithm('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   m = ltpda_algorithm('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   m = ltpda_algorithm('foo.txt')                  %%%%%%%%%%
            %%%%%%%%%%   m = ltpda_algorithm('foo.dat')                  %%%%%%%%%%
            %%%%%%%%%%   m = ltpda_algorithm({'foo1.mat', 'foo2.mat'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, args{1});
            
          elseif isstruct(args{1})
            %%%%%%%%%%   a1 = ao(struct)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isa(args{1}, 'plist')
            %%%%%%%%%%   a1 = ao(plist-object)   %%%%%%%%%%
            utils.helper.msg(msg.PROC1, 'constructing from plist');
            pl         = args{1};
      
            if pl.isparam_core('filename') || pl.isparam_core('filenames')
              
              %-----------------------------------------------------
              %--- Construct from file
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, args{1});
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn') || pl.isparam_core('id')
              
              %-----------------------------------------------------
              %--- Construct from repository
              %-----------------------------------------------------
              utils.helper.msg(msg.PROC2, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif pl.isparam_core('built-in')
              %-----------------------------------------------------
              %--- Construct from built-in model
              %-----------------------------------------------------
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            else
              % build an empty algorithm from the plist and default values
              % Apply defaults to plist
              dpl        = obj.getDefaultPlist('default');
              obj.params = applyDefaults(dpl, pl);
              obj.finalise();
            end
            
          else
            error('### Unknown single input constructor');
          end
        case 2
          if isa(args{1}, 'org.apache.xerces.dom.ElementImpl') && isa(args{2}, 'history')
            %%%%%%%%%%   obj = ao(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, args{1}, args{2});
          elseif iscellstr(args)
            obj = fromFile(obj, fullfile(args{:}));
          else
            error('### Unknown constructor with two inputs.\n### The arguments are from type ''%s'' [%dx%d] and ''%s'' [%dx%d]', class(args{1}), size(args{1}), class(args{2}), size(args{2}));
            
          end
          
        otherwise
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   other inputs   %%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if iscellstr(varargin)
            %%%%%%%%%%   ltpda_algorithm('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            error('### Unknown input arguments... ')
          end
      
      end
      
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (public)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    
    function varargout = process(varargin)
      
      % process inputs
      algo   = varargin{1};
      
      % Collect input variable names
      in_names = cell(size(varargin));
      try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
      in_names = in_names(2:end); % drop algorithm variable name
      
      % Collect and copy all objects
      objs_in = varargin(2:end);
      names   = {};
      objs    = {};
      for kk=1:numel(objs_in)
        obj = objs_in{kk};
        if isa(obj, 'ltpda_uoh')
          objs  = [objs {copy(obj, nargout)}];
          names = [names in_names(kk)];
        end
      end
      
      % call main
      out = main(algo, objs, names);
      
      % Set output
      varargout = utils.helper.setoutputs(nargout, out);
    end
    
    function pl = generateConstructorPlist(obj)
      pl = copy(obj.params, 1);
    end
    
    function varargout = copy(new, old, deepcopy, addHist)
      
      if deepcopy
        obj = copy@ltpda_uoh(new, old, 1, addHist);
        
        for kk = 1:numel(obj)
          %%% copy all fields of the ltpda_algorithm class
          obj(kk).package  = old(kk).package;
          obj(kk).category = old(kk).category;
          if ~isempty(old(kk).params)
            obj(kk).params = copy(old(kk).params,1);
          end
        end
        
      else
        obj = old;
      end
      
      varargout{1} = obj;
    end
    
    function disp(varargin)
      for kk=1:numel(varargin)
        utils.helper.objdisp(varargin{kk});
      end
    end
    
    function varargout = char(obj)
      varargout{1} = obj.name;
    end
    
  end % methods (Access = public)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (public, Hidden)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Hidden = true)
    
    function addHistory(varargin)
      
      if ~isa(varargin{2}, 'minfo')
        algo     = varargin{1};
        obj      = varargin{2};
        stepName = varargin{3};
        pl       = varargin{4};
        inhists  = [varargin{5:end}];
        ii       = minfo(stepName, class(algo), algo.package, algo.category, '', [], []);
        inhists  = [algo.hist inhists];
      else
        obj     = varargin{1};
        ii      = varargin{2};
        pl      = varargin{3};
        inhists = [varargin{5:end}];
      end
      
      addHistory@ltpda_uoh(obj, ii, pl, {}, inhists);
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (public, Static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static=true)
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, mfilename('class'));
    end
    
    function reports = run_tests(name)
      
      obj       = eval(name);
      test_list = feval([name '.test_list']);
      
      count   = 0;
      failed  = 0;
      reports = [];
      for tt=1:numel(test_list)
        [path, name, ext] = fileparts(test_list{tt});
        count     = count + 1;
        cp        = pwd();
        r.name    = name;
        r.path    = path;
        r.message = '';
        try
          cd(path)
          f = str2func(name);
          f(obj)
          fprintf('.');
          r.message = 'Passed';
        catch Me
          r.message = getReport(Me, 'basic');
          fprintf('X');
          failed = failed + 1;
        end
        reports = [reports r];
        cd(cp);
      end
      
      fprintf('\n');
      
      for kk=1:numel(reports)
        if ~isempty(reports(kk).message)
          fprintf('%03d: %s: %s\n', kk, reports(kk).name, reports(kk).message);
        end
      end
      
    end
    
    function tests = test_list(varargin)
      tests = ltpda_algorithm.list_tests(mfilename('class'));
    end
    
    function tests = list_tests(varargin)
      % LIST_TESTS returns a cell-array of tests for the given class.
      %
      %
      %
      
      [path, name, ext] = fileparts(which(varargin{1}));
      
      testDir = fullfile(path, 'tests');
      
      files = utils.prog.filescan(testDir, '.m');
      tests = [];
      for kk=1:numel(files)
        [path, name, ext] = fileparts(files{kk});
        if strncmp(name, 'test_', 5)
          tests = [tests files(kk)];
        end
        
      end
    end
    
    function plout = getDefaultPlist(varargin)
      persistent pl;
      if isempty(pl)
        pl = ltpda_algorithm.buildplist(varargin{:});
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = ltpda_algorithm.newarray([varargin{:}]);
    end
    
  end % methods (Access = public, Static=true)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (protected)                      %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access=protected)
    vararout = main(varargin)   
        
    function finalise(obj)
      plh = obj.params;
      plh.getSetRandState();
      obj.addHistory(obj, class(obj), plh, []);
    end

    function ii = info(algo)
      ii = minfo(algo.name, class(algo), algo.package, algo.category, '', [], algo.getDefaultPlist('default'));
    end
    
    function ii = processInfo(algo)
      ii = minfo('process', class(algo), algo.package, algo.category, '', [], []);
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (static, protected)                      %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static, Access = protected)
    function pl = buildplist(varargin)
      pl = plist.RAND_STREAM();
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                       Methods (public, static, Hidden)                    %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
   methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
end

% END
