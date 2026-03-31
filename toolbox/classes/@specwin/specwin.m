% SPECWIN spectral window object class constructor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SPECWIN spectral window object class constructor.
%              Create a spectral window from libSpecWin.
%
% SUPERCLASSES: ltpda_nuo < ltpda_obj
%
%  SPECWIN CONSTRUCTORS:
%
%       w = specwin()                  - creates an empty object
%       w = specwin(w)                 - copies a specwin object
%       w = specwin('name')            - creates the specified specwin object
%       w = specwin('name', N)         - creates a specwin object of a
%                                        particular type and length.
%       w = specwin('Kaiser', N, psll) - create a specwin Kaiser window
%                                        with the prescribed psll.
%
% 'name' should be one of the following standard windows:
%
%    Rectangular, Welch, Bartlett, Hanning, Hamming,
%    Nuttall3, Nuttall4, Nuttall3a, Nuttall3b, Nuttall4a
%    Nuttall4b, Nuttall4c, BH92, SFT3F, SFT3M, FTNI, SFT4F, SFT5F
%    SFT4M, FTHP, HFT70, FTSRS, SFT5M, HFT90D, HFT95, HFT116D
%    HFT144D, HFT169D, HFT196D, HFT223D, HFT248D
%
% SEE ALSO:    ltpda_obj, ltpda_nuo
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Hidden = true) specwin < ltpda_nuo
  
  %------------------------------------------------
  %---------- Private read-only Properties --------
  %------------------------------------------------
  properties (SetAccess = private)
    type        = ''; % name of window object
    alpha       = []; % alpha parameter for various window functions
    psll        = []; % peak sidelobe level
    rov         = []; % recommended overlap
    nenbw       = []; % normalised equivalent noise bandwidth
    w3db        = []; % 3 dB bandwidth in bins
    flatness    = []; % window flatness
    levelorder  = []; % levelling coefficient
    skip        = []; % number of bins to skip
  end
  
  properties (SetAccess = public)
    len         = 0;  % window number of samples
  end
  
  properties (Dependent = true, SetAccess = private, Hidden = true)
    win         = []; % window samples
    ws          = 0;  % sum of window values
    ws2         = 0;  % sum of squares of window values
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Check property setting                           %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function obj = set.win(obj, vals)
      obj.len = length(vals);
    end
    
    function obj = set.ws(obj, ~)
    end
    
    function obj = set.ws2(obj, ~)
    end
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Dependent property methods                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods
    function win = get.win(obj)
      win_name = sprintf('win_%s', lower(obj.type));
      win = feval(win_name, obj, 'build');
    end % win get method
    
    function ws = get.ws(obj)
      if obj.len ~= 0
        % In this case, we need to calculate the property 'win' before
        ws = sum(obj.win);
      else
        ws = 0;
      end
    end
    
    function ws2 = get.ws2(obj)
      if obj.len ~= 0
        % In this case, we need to calculate the property 'win' before
        ws2 = sum(obj.win .* obj.win);
      else
        ws2 = 0;
      end
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                                Constructor                                %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    function ww = specwin(varargin)
      
      import utils.const.*
      utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
      
      %%%%%%%%%%   Set dafault values   %%%%%%%%%%
      
      switch nargin
        case 0
          utils.helper.msg(msg.OPROC1, 'empty constructor');
          
        case 1
          if isa(varargin{1}, 'specwin')
            utils.helper.msg(msg.OPROC1, 'copy constructor');
            %%%%%%%%%%   spw = specwin(specwin-object)   %%%%%%%%%%
            % copy existing specwin
            ww = copy(varargin{1}, 1);
            
          elseif isstruct(varargin{1})
            %%%%%%%%%%   spw = specwin(struct)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from struct');
            ww = fromStruct(ww, varargin{1});
            
          elseif ischar(varargin{1})
            %%%%%%%%%%   spw = specwin(window-name)   %%%%%%%%%%
            utils.helper.msg(msg.OPROC1, 'constructing from string');
            N = find_core(specwin.getInfo('specwin', 'From Window').plists, 'N');
            ww = get_window(ww, varargin{1}, N);
            
          else
            error('### Unknown 1 argument constructor for specwin object.')
          end
          
        case 2
          utils.helper.msg(msg.OPROC1, 'constructing type %s', char(varargin{1}));
          if ischar(varargin{1})
            %%%%%%%%%%   spw = specwin('Win_type', N)   %%%%%%%%%%
            ww = get_window(ww, varargin{1}, varargin{2});
            
          elseif isa(varargin{1}, 'org.apache.xerces.dom.ElementImpl') && ...
              isa(varargin{2}, 'history')
            %%%%%%%%%%   obj = specwin(DOM node, history-objects)   %%%%%%%%%%
            ww = fromDom(ww, varargin{1}, varargin{2});
            
          else
            error('### Unknown 2 argument constructor for specwin object.')
          end
          
        case 3
          utils.helper.msg(msg.OPROC1, 'constructing type %s', varargin{1});
          %%%%%%%%%%   spw = specwin('Kaiser', N, psll)                 %%%%%%%%%%
          %%%%%%%%%%   spw = specwin('levelledHanning', N, levelcoeff)  %%%%%%%%%%
          ww = get_window(ww, varargin{1}, varargin{2}, varargin{3});
          
        otherwise
          error('### Unknown number of constructor arguments');
      end % End of constructor
      
    end
    
  end % End constructor
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Public)                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true)
    
    function ww = getTypes()
      ww = {...
        'Rectangular', 'Welch', 'Bartlett', 'Hanning', 'Hamming',...
        'Nuttall3', 'Nuttall4', 'Nuttall3a', 'Nuttall3b', 'Nuttall4a',...
        'Nuttall4b', 'Nuttall4c', 'BH92', 'SFT3F', 'SFT3M', 'FTNI', 'SFT4F', 'SFT5F',...
        'SFT4M', 'FTHP', 'HFT70', 'FTSRS', 'SFT5M', 'HFT90D', 'HFT95', 'HFT116D',...
        'HFT144D', 'HFT169D', 'HFT196D', 'HFT223D', 'HFT248D', ...
        'Kaiser', ...
        'levelledHanning'...
        };
    end
    
    function ii = getInfo(varargin)
      ii = utils.helper.generic_getInfo(varargin{:}, 'specwin');
    end
    
    function out = SETS()
      out = {'Default', 'From Window'};
    end
    
    function out = getDefaultPlist(set)
      switch lower(set)
        case 'default'
          out = plist();
        case 'from window'
          prefs = getappdata(0, 'LTPDApreferences');
          out = plist('type', char(prefs.getMiscPrefs.getDefaultWindow), 'N', 0);
        otherwise
          error('### Unknown set [%s]', set);
      end
    end
    
    function obj = initObjectWithSize(varargin)
      obj = specwin.newarray([varargin{:}]);
    end
    
  end % End static methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                          Methods (Static, Private)                        %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Access = private)
    
    varargout = kaiser_alpha(varargin)
    varargout = kaiser_flatness(varargin)
    varargout = kaiser_nenbw(varargin)
    varargout = kaiser_rov(varargin)
    varargout = kaiser_w3db(varargin)
    
  end % End static private methods
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                         Methods (static, hidden)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Static = true, Hidden = true)
    varargout = loadobj(varargin)
    varargout = update_struct(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (hidden)                             %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Hidden = true)
    varargout = attachToDom(varargin)
    varargout = fromDom(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (protected)                          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = protected)
    varargout = fromStruct(obj, obj_struct)
    
    varargout = get_window(varargin)
    varargout = win_bh92(varargin)
    varargout = win_bartlett(varargin)
    varargout = win_fthp(varargin)
    varargout = win_ftni(varargin)
    varargout = win_ftsrs(varargin)
    varargout = win_hft116d(varargin)
    varargout = win_hft144d(varargin)
    varargout = win_hft169d(varargin)
    varargout = win_hft196d(varargin)
    varargout = win_hft223d(varargin)
    varargout = win_hft248d(varargin)
    varargout = win_hft70(varargin)
    varargout = win_hft90d(varargin)
    varargout = win_hft95(varargin)
    varargout = win_hamming(varargin)
    varargout = win_hanning(varargin)
    varargout = win_nuttall3(varargin)
    varargout = win_nuttall3a(varargin)
    varargout = win_nuttall3b(varargin)
    varargout = win_nuttall4(varargin)
    varargout = win_nuttall4a(varargin)
    varargout = win_nuttall4b(varargin)
    varargout = win_nuttall4c(varargin)
    varargout = win_rectangular(varargin)
    varargout = win_sft3f(varargin)
    varargout = win_sft3m(varargin)
    varargout = win_sft4f(varargin)
    varargout = win_sft4m(varargin)
    varargout = win_sft5f(varargin)
    varargout = win_sft5m(varargin)
    varargout = win_welch(varargin)
    varargout = win_kaiser(varargin)
    varargout = win_levelledhanning(varargin)
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                              Methods (private)                            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  methods (Access = private)
  end
  
end % End classdef

