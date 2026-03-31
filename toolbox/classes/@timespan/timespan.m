% TIMESPAN timespan object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  TIMESPAN timespan object class constructor.
%               Create a timespan object.
%
% CONSTRUCTORS:
%
%       ts = timespan()
%       ts = timespan('file_name.mat');
%       ts = timespan('file_name.xml');
%       ts = timespan( time,       time)
%       ts = timespan(time,       '14:00:05')
%       ts = timespan('14:00:00',  time)
%       ts = timespan('14:00:00', '14:00:05')
%       ts = timespan(30000, 50000)
%       ts = timespan(20000, 30000, 'HH:MM:SS')
%       ts = timespan([1000 2000]);
%       ts = timespan([time(1000) time(2000)]);
%       ts = timespan(plist)
%       ts = timespan(ao-object)
%
% SUPPORTED TIMEFORMATS:
%
%       dd-mm-yyyy HH:MM:SS             yyyy - year     (000-9999)
%       dd.mm.yyyy HH:MM:SS             mm   - month    (1-12)
%       dd-mm-yyyy HH:MM:SS.FFF         dd   - day      (1-31)
%       dd.mm.yyyy HH:MM:SS.FFF         HH   - hour     (00-24)
%       HH:MM:SS dd-mm-yyyy             MM   - minutes  (00-59)
%       HH:MM:SS dd.mm.yyyy             SS   - seconds  (00-59)
%       HH:MM:SS.FFF dd-mm-yyyy         FFF  - milliseconds (000-999)
%       HH:MM:SS.FFF dd.mm.yyyy
%       MM:SS
%       MM:SS.FFF
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'timespan')">Parameters Description</a>
%
% SEE ALSO:    ltpda_uoh, ltpda_uo, ltpda_obj, plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef timespan < ltpda_uoh
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Property definition                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %---------- Protected read-only Properties ----------
  properties (SetAccess = protected)
    startT     = time(0); % Start time of the time span. (time-object)
    endT       = time(0); % End time of the time span.   (time-object)
    interval   = ''; % Interval between start/end time
  end
  
  properties (Dependent=true)
    nsecs = 0;
  end
  
  %---------- Constant Properties ----------
  properties (Constant = true)
    timeformat; % timeformat of the time span (see preferences)
    timezone; % timezone of the time span (see preferences)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Constant Property Methods                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    function value = get.timezone(obj)
      p = getappdata(0, 'LTPDApreferences');
      value = char(p.getTimePrefs.getTimeTimezone);
      if ischar(value)
        value = java.util.TimeZone.getTimeZone(value);
      end
    end
    
    function value = get.timeformat(obj)
      p = getappdata(0, 'LTPDApreferences');
      value = char(p.getTimePrefs.getTimestringFormat);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Dependent property methods                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function value = get.interval(obj)
      value = computeInterval(obj);
    end
    function value = get.nsecs(obj)
      value = double(obj.endT) - double(obj.startT);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function set.startT(obj, val)
      if ischar(val) || isnumeric(val)
        val = time(val);
      end
      if ~isa(val, 'time')
        error('### The value for the property ''startT'' must be a time-object.\nBut it is from the class [%s]',class(val));
      end
      obj.startT = val;
    end
    function set.endT(obj, val)
      if ischar(val) || isnumeric(val)
        val = time(val);
      end
      if ~isa(val, 'time')
        error('### The value for the property ''endT'' must be a time-object.\nBut it is from the class [%s]',class(val));
      end
      obj.endT = val;
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = timespan(varargin)
      
      % check if the caller was a user of another method
      callerIsMethod = utils.helper.callerIsMethod;
      
      import utils.const.*
      if ~callerIsMethod
        utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      end
      
      % Collect all timespan objects
      [ts, ~, rest] = utils.helper.collect_objects(varargin(:), 'timespan');
      
      if isempty(rest) && ~isempty(ts)
        % Do copy constructor and return
        utils.helper.msg(msg.OPROC1, 'copy constructor');
        obj = copy(ts, 1);
        for kk=1:numel(obj)
          obj(kk).addHistory(timespan.getInfo('timespan', 'None'), [], [], obj(kk).hist);
        end
        return
      end
      
      if ~isempty(rest) && all(cellfun(@(x) isa(x, 'ao'), rest))
        %%%%%%%%%%   ts = timespan(ao)            %%%%%%%%%%
        %%%%%%%%%%   ts = timespan(ao, ao)        %%%%%%%%%%
        %%%%%%%%%%   ts = timespan(ao, ao, ...)   %%%%%%%%%%
        obj = fromAOs(obj, plist('aos', [varargin{:}]));
        return
      end
      
      switch nargin
        case 0
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   no input   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          obj.addHistory(timespan.getInfo('timespan', 'None'), timespan.getDefaultPlist('Default'), [], []);
          
        case 1
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   one input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if ischar(varargin{1}) || iscell(varargin{1})
            
            %%%%%%%%%%   ts = timespan('foo.mat')                  %%%%%%%%%%
            %%%%%%%%%%   ts = timespan('foo.xml')                  %%%%%%%%%%
            %%%%%%%%%%   ts = timespan({'foo1.xml', 'foo2.xml'})   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(varargin{1}));
            obj = fromFile(obj, varargin{1});
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   ts = timespan(struct)   %%%%%%%%%%
            
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            obj = fromStruct(obj, varargin{1});
            
          elseif isa(varargin{1}, 'plist')
            %%%%%%%%%%   ts = timespan(plist)   %%%%%%%%%%
            
            pl = varargin{1};
            
            if pl.isparam_core('filename') || pl.isparam_core('filenames')
              %-----------------------------------------------------
              %--- Construct from file
              %-----------------------------------------------------
              utils.helper.msg(msg.OPROC1, 'constructing from file %s', utils.helper.val2str(pl.mfind('filename', 'filenames')));
              obj = fromFile(obj, pl);
              
            elseif pl.isparam_core('hostname') || pl.isparam_core('conn')
              %-----------------------------------------------------
              %--- Construct from repository
              %-----------------------------------------------------
              utils.helper.msg(msg.OPROC1, 'constructing from repository %s', pl.find_core('hostname'));
              obj = obj.fromRepository(pl);
              
            elseif (pl.isparam_core('startT') || pl.isparam_core('start')) && ...
                (pl.isparam_core('endT')   || pl.isparam_core('end') || pl.isparam_core('stop'))
              %-----------------------------------------------------
              %--- Construct from start and end times
              %-----------------------------------------------------
              utils.helper.msg(msg.OPROC1, 'constructing from start/end times');
              obj = obj.fromTimespanDef(pl, callerIsMethod);
              
            elseif pl.isparam_core('built-in')
              %-----------------------------------------------------
              %--- Construct from built-in model
              %-----------------------------------------------------
              utils.helper.msg(msg.OPROC1, 'constructing from built-in model');
              obj = fromModel(obj, pl);
              
            elseif pl.isparam_core('aos')
              %-----------------------------------------------------
              %--- Construct from AOs
              %-----------------------------------------------------
              utils.helper.msg(msg.OPROC1, 'constructing from analysis objects');
              obj = fromAOs(obj, pl);
              
            else
              pl = applyDefaults(timespan.getDefaultPlist('Default'), pl);
              obj.setObjectProperties(pl);
              obj.addHistory(timespan.getInfo('timespan', 'None'), pl, [], []);
            end
            
          elseif isa(varargin{1}, 'time') || isa(varargin{1}, 'double')
            %%%%%%%%%%   ts = timespan([time time])   %%%%%%%%%%
            %%%%%%%%%%   ts = timespan([200000 300000])  %%%%%%%%%%
            in_vec = varargin{1};
            if numel(in_vec) == 2
              pli = plist('start', in_vec(1), 'stop', in_vec(2));
              obj = obj.fromTimespanDef(pli, callerIsMethod);
            else
              error(timespan.createErrorStr(varargin{:}));
            end
            
          elseif isa(varargin{1}, 'LPFInv')
            inv1 = varargin{1};
            pli = plist('start',inv1.t0,'stop',inv1.t0+inv1.nsecs);
            obj = obj.fromTimespanDef(pli,callerIsMethod);
            
          else
            error('### Unknown single argument constructor.');
          end
          
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%   two input   %%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if (ischar(varargin{1}) || isa(varargin{1}, 'time') || isnumeric(varargin{1})) && ...
              (ischar(varargin{2}) || isa(varargin{2}, 'time') || isnumeric(varargin{2}))
            %%%%%%%%%%  ts = timespan('14:00:00', '14:00:05')   %%%%%%%%%%
            %%%%%%%%%%  ts = timespan('14:00:00', time)         %%%%%%%%%%
            %%%%%%%%%%  ts = timespan(time, time)               %%%%%%%%%%
            %%%%%%%%%%  ts = timespan(time, '14:00:05')         %%%%%%%%%%
            
            %%%%%%%%%%   timespan('dir', 'objs.xml')   %%%%%%%%%%
            if iscellstr(varargin) && exist(fullfile(varargin{:}), 'file')
              obj = fromFile(obj, fullfile(varargin{:}));
              
            else
              utils.helper.msg(msg.OPROC1, 'constructing from start/end time');
              pli = plist('start', varargin{1}, 'stop', varargin{2});
              obj = obj.fromTimespanDef(pli, callerIsMethod);
            end
            
          elseif (isa(varargin{1}, 'database') || isa(varargin{1}, 'java.sql.Connection')) && isnumeric(varargin{2})
            %%%%%%%%%%  f = timespan(database, IDs)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'retrieve from repository');
            obj = obj.fromRepository(plist('conn', varargin{1}, 'id', varargin{2}));
            
          elseif isa(varargin{1}, 'timespan') && isa(varargin{2}, 'plist') && isempty(varargin{2}.params)
            %%%%%%%%%%  f = timespan(timespan-object, <empty plist>)   %%%%%%%%%%
            obj = timespan(varargin{1});
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = timespan(DOM node, history-objects)   %%%%%%%%%%
            obj = fromDom(obj, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'ltpda_uoh') && isa(varargin{2}, 'plist')
            %%%%%%%%%%%   timespan(<ltpda_uoh>-object, plist-object)   %%%%%%%%%%
            % always recreate from plist
            
            % If we are trying to load from file, and the file exists, do
            % that. Otherwise, copy the input object.
            if varargin{2}.isparam_core('filename')
              if exist(fullfile('.', find_core(varargin{2}, 'filename')), 'file') == 2
                obj = timespan(varargin{2});
              else
                obj = timespan(varargin{1});
              end
            else
              obj = timespan(varargin{2});
            end
            
          else
            error(timespan.createErrorStr(varargin{:}));
          end
          
        case 3
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%   three input   %%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          if  (ischar(varargin{1}) || isnumeric(varargin{1}) || isa(varargin{1}, 'time')) && ...
              (ischar(varargin{2}) || isnumeric(varargin{2}) || isa(varargin{2}, 'time')) && ...
              ischar(varargin{3})
            %%%%%%%%%%  obj = timespan('14:00:00', '14:00:05', 'HH:MM:SS')  %%%%%%%%%%
            %%%%%%%%%%  obj = timespan(  200000  ,   300000  , 'HH:MM:SS')  %%%%%%%%%%
            %%%%%%%%%%  obj = timespan(time(2000), time(3000), 'HH:MM:SS')  %%%%%%%%%%
            %%%%%%%%%%  obj = timespan('00:01:00',   300000  , 'HH:MM:SS')  %%%%%%%%%%
            
            %%%%%%%%%%   timespan('to', 'dir', 'objs.xml')   %%%%%%%%%%
            
            if iscellstr(varargin) && exist(fullfile(varargin{:}), 'file')
              obj = fromFile(obj, fullfile(varargin{:}));
              
            else
              utils.helper.msg(msg.OPROC1, 'constructing from start/end and timeformat');
              pl = plist('STARTT', varargin{1}, 'ENDT', varargin{2}, 'timeformat', varargin{3});
              obj = obj.fromTimespanDef(pl, callerIsMethod);
            end
            
          else
            error(timespan.createErrorStr(varargin{:}));
          end
          
        otherwise
          
          if iscellstr(varargin)
            %%%%%%%%%%   timespan('path', 'to', 'dir', 'objs.xml')   %%%%%%%%%%
            obj = fromFile(obj, fullfile(varargin{:}));
            
          else
            [tss, ~, rest] = utils.helper.collect_objects(varargin(:), 'timespan');
            
            %%% Do we have a list of TIMESPANs as input
            if ~isempty(tss) && isempty(rest)
              obj = timespan(tss);
            else
              error(timespan.createErrorStr(varargin{:}));
            end
          end
      end
      
      % Consistency check
      for ll = 1:numel(obj)
        if obj(ll).startT.utc_epoch_milli > obj(ll).endT.utc_epoch_milli
          error('### The start time is larger than the end time.');
        end
      end
      
    end % End constructor
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (public)                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public)
    varargout = copy(varargin)
    varargout = setStartT(varargin)
    varargout = setEndT(varargin)
    varargout = double(varargin)
    varargout = plus(varargin)
    varargout = minus(varargin)
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
    
    function out = doubleToHumanInterval(varargin)
      % DOUBLETOHUMANINTERVAL returns a cell-array of strings, each
      % representing a human readable form for the input numbers when
      % interpretted as time intervals.
      %
      % CALL
      %          out = timespan.doubleToHumanInterval(nsecs)
      %
      %
      
      out = {};
      for kk=1:numel(varargin)
        
        if ~isnumeric(varargin{kk})
          warning('Skipping input %d since it is not a number', kk);
        else
          
          nsecs = varargin{kk};
          
          days  = floor(nsecs/86400);
          secs  = nsecs - days*86400;
          hours = floor(secs/3600);
          secs  = secs - hours*3600;
          mins  = floor(secs/60);
          secs  = secs - mins*60;
          
          if days == 1
            dstr = 'day';
          else
            dstr = 'days';
          end
          
          if hours == 1
            hstr = 'hour';
          else
            hstr = 'hours';
          end
          
          if mins == 1
            mstr = 'minute';
          else
            mstr = 'minutes';
          end
          
          if secs == 1
            sstr = 'second';
          else
            sstr = 'seconds';
          end
          
          if days > 0
            str = sprintf('%d %s, %d %s, %d %s, %0.2f %s', days, dstr, hours, hstr, mins, mstr, secs, sstr);
          elseif hours > 0
            str = sprintf('%d %s, %d %s, %0.2f %s', hours, hstr, mins, mstr, secs, sstr);
          elseif mins > 0
            str = sprintf('%d %s, %0.2f %s', mins, mstr, secs, sstr);
          else
            str = sprintf('%0.2f %s', secs, sstr);
          end
          
          out = [out {str}];
        end
        
      end % End loop over inputs
      
      if numel(out) == 1
        out = out{1};
      end
      
    end % End doubleToHumanInterval
    
    
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
      out = [SETS@ltpda_uoh, {'From Timespan Definition', 'From AOs'}];
    end
    
    function plout = getDefaultPlist(set)
      persistent pl;
      persistent lastset;
      if exist('pl', 'var') == 0 || isempty(pl) || ~strcmp(lastset, set)
        pl = timespan.buildplist(set);
        lastset = set;
      end
      plout = pl;
    end
    
    function obj = initObjectWithSize(varargin)
      obj = timespan.newarray([varargin{:}]);
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = public, Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                             Methods (protected)                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(varargin)
    varargout = fromAOs(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Methods (protected, static)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected, Static = true)
    function out = buildplist(set)
      
      if ~utils.helper.ismember(lower(timespan.SETS), lower(set))
        error('### Unknown set [%s]', set);
      end
      
      out = plist();
      out = timespan.addGlobalKeys(out);
      
      % Remove the global key 'timespan'
      out.remove('timespan');
      
      out = buildplist@ltpda_uoh(out, set);
      
      switch lower(set)
        
        case 'from timespan definition'
          p = param({'start', 'The starting time.'}, paramValue.EMPTY_STRING);
          p.addAlternativeKey('startT');
          out.append(p);
          
          p = param({'stop', 'The ending time.'}, paramValue.EMPTY_STRING);
          p.addAlternativeKey('endT');
          p.addAlternativeKey('end');
          out.append(p);
          
          p = param({'timezone', 'Timezone.'}, paramValue.TIMEZONE);
          out.append(p);
          
          p = param({'timeformat', 'Time format.'}, paramValue.STRING_VALUE(''));
          out.append(p);
          
        case 'from aos'
          p = param({'aos', 'The starting time.'}, paramValue.EMPTY_DOUBLE);
          out.append(p);
          
      end
    end % function out = getDefaultPlist(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Methods (private)                               %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
    obj = fromTimespanDef(obj, pli, callerIsMethod)
    str = computeInterval(obj)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (private, static)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private, Static = true)
  end
  
end % End classdef

