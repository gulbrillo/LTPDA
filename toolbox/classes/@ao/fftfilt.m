% FFTFILT overrides the fft filter function for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FFTFILT overrides the fft filter function for analysis objects.
%              Applies the input filter to the input analysis
%              object in the frequency domain. 
% 
%
% CALL:        >> b = fftfilt(a,smodel); b = fftfilt(a,plist('filter',smodel)) 
%              >> b = fftfilt(a,mfir); b = fftfilt(a,plist('filter',mfir))
%              >> b = fftfilt(a,miir); b = fftfilt(a,plist('filter',miir))
%              >> b = fftfilt(a,ltpda_tf); b = fftfilt(a,plist('filter',ltpda_tf))
%              >> b = fftfilt(a,plist('filter',c)) % c is an AO used as a
%                 filter
%
% INPUTS:      
%                   a - input analysis object
%      one of
%              smodel - a model to filter with. The x-dependency must
%                           be on frequency ('f').
%                mfir - an FIR filter
%                miir - an IIR filter
%                tf   - an ltpda_tf object
%                       including:
%                         - pzmodel
%                         - rational
%                         - parfrac
%                  ao - a frequency-series AO. This must have the
%                       correct frequency base to match the FFT'd input
%                       data. You must input it in a plist
%
% OUTPUTS:
%              b    - output analysis object containing the filtered data.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'fftfilt')">Parameters Description</a>
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% caller is method interface:
% 
%     a = fftfilter(a1, a2, ..., filt)
% 

function varargout = fftfilt(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % Collect input variable names
  in_names = cell(size(varargin));
  
  if callerIsMethod
    
    as        = [varargin{1:end-1}];
    filt      = varargin{end};
    ao_invars = {};
    mobjs     = [];
    tfobjs    = [];
    pl        = [];
    
  else
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all AOs and plists
    [as, ao_invars]     = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    [filt, f_invars]    = utils.helper.collect_objects(varargin(:), 'ltpda_filter', in_names);
    [mobjs, md_invars]  = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
    [tfobjs, tf_invars] = utils.helper.collect_objects(varargin(:), 'ltpda_tf', in_names);
    pl                  = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  end
  
  % Make copies or handles to inputs
  bs   = copy(as, nargout);
  
  
  % Filter with a smodel object
  if ~isempty(mobjs)
    filt = mobjs;
  elseif ~isempty(tfobjs)
    filt = tfobjs;
  end

  if isempty(filt)
    filt = find_core(pl, 'filter');
  end
  
  % combine plists
  if isempty(filt)
    cset = 'standard type filter';
  else
    cset = 'custom filter';
  end
  
  pl = applyDefaults(getDefaultPlist(cset), pl);
  
  % get number of Bins for zero padding
  Npad = find_core(pl,'Npad');
  
  switch lower(cset)
    case 'custom filter'

      % get initial conditions
      inConds = find_core(pl,'Initial Conditions');

      % check initial conditions
      if ~isempty(inConds)
        if iscell(inConds) && numel(inConds) ~= numel(bs)
          error('### Please give the proper number of initial conditions')
        end
        if ~iscell(inConds) && numel(bs)>1
          error('### Please give the initial conditions in a cell-array')
        else
          inConds = {inConds};
        end
      end

      if isa(filt, 'smodel')
        inCondsMdl = repmat(smodel(), numel(bs), 1);
        for ii = 1:numel(bs)
          if ~isempty(inConds)
            N = numel(inConds{ii});
            expr = '';
            ix = 1;
            for jj = N-1:-1:0
              expr = [expr,sprintf('+(2*pi*i*f).^%i*%g',jj,inConds{ii}(ix))];
              ix = ix+1;
            end
            inCondsMdl(ii) = smodel(plist('expression', expr, 'xvar', 'f'));
          end
        end
      else
         inCondsMdl = cell(size(bs));
      end
      
    case 'standard type filter'
      filt = find_core(pl,'type');
      fc   = find_core(pl,'fc');
      gain = find_core(pl,'gain');
      iunits = find_core(pl,'iunits');
      ounits = find_core(pl,'ounits');
      
  end
  
  for ii = 1:numel(bs)
    % keep the history to suppress the history of the intermediate steps
    inhist = bs(ii).hist;

    % make sure we operate on physical frequencies   
    switch class(filt)
      case 'smodel'
        switch filt.xvar{1}
          case 'f'
            % Nothing to do
          case 's'
            % I need to map from 's' to 'f'
            filt.setTrans('2*pi*i');
          otherwise
            error('### The filter smodel must have xvar = ''s'' or ''f''');
        end
        % call core method of the fftfilt
        bs(ii).fftfilt_core(filt, Npad, inCondsMdl(ii));  
        
      case 'char'
        
        % call core method of the fftfilt
        bs(ii).fftfilt_core(filt, Npad, [], fc, gain, iunits, ounits);
        
      otherwise
        
        % call core method of the fftfilt
        bs(ii).fftfilt_core(filt, Npad, inCondsMdl(ii));
        
    end  
    
    if ~callerIsMethod
      % Set name
      bs(ii).setName(sprintf('fftfilt(%s)', ao_invars{ii}));
      % Add history
      switch class(filt)
        case 'char'
          bs(ii).addHistory(getInfo('None'), pl, ao_invars(ii), [inhist]);
        otherwise
          bs(ii).addHistory(getInfo('None'), pl, ao_invars(ii), [inhist filt(:).hist]);
      end
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end


% %--------------------------------------------------------------------------
% % Get Info Object
% %--------------------------------------------------------------------------
% function ii = getInfo(varargin)
%   if nargin == 1 && strcmpi(varargin{1}, 'None')
%     sets = {};
%     pl   = [];
%   else
%     sets = {'Default'};
%     pl   = getDefaultPlist();
%   end
%   % Build info object
%   ii = minfo(mfilename, 'ao', 'ltpda', utils.const.categories.sigproc, '', sets, pl);
% end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pl = getDefaultPlist(sets{1});
  else
    sets = SETS();
    % get plists
    pl(size(sets)) = plist;
    for kk = 1:numel(sets)
      pl(kk) =  getDefaultPlist(sets{kk});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  out = {...
    'custom filter', ...
    'standard type filter',    ...
    };
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
% function plout = getDefaultPlist()
%   persistent pl;  
%   if ~exist('pl', 'var') || isempty(pl)
%     pl = buildplist();
%   end
%   plout = pl;  
% end

function plout = getDefaultPlist(set)
  persistent pl;  
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;  
end

% function pl = buildplist()
function pl = buildplist(set)

  pl = plist();
  
  % Number of bins for zero padding
  p = param({'Npad', 'Number of bins for zero padding.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  
  switch lower(set)
    case 'custom filter'
      % Filter
      p = param({'filter', 'The filter to apply to the data.'}, paramValue.EMPTY_STRING);
      pl.append(p);

      % Initial conditions
      p = param({'Initial Conditions', ['A cell containing the arrays of initial conditions, one '...
          'for each system being solved, '...
          'starting from the lower order to the maximum allowed. '...
          'It assumed that the underlying system follows a linear differential equation with constant coefficients. '...
          'For example, if the system is the Newton '...
          '2nd-order equation of motion, than the array contains the initial position and the '...
          'initial velocity.']}, paramValue.EMPTY_CELL);
      pl.append(p);
      
    case 'standard type filter'
      % Type
      p = param({'type','Choose the filter type.'}, {2, {'highpass', 'lowpass', 'bandpass', 'bandreject'}, paramValue.SINGLE});
      pl.append(p);
      
      % Fc
      p = param({'fc','The roll-off frequency [Hz].'},  paramValue.DOUBLE_VALUE([0.1 0.4]));
      pl.append(p);
      
      % Gain
      p = param({'gain','The gain of the filter.'},  paramValue.DOUBLE_VALUE(1));
      pl.append(p);
      
      % Iunits
      p = param({'iunits','The input units of the filter.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
      % Ounits
      p = param({'ounits','The output units of the filter.'}, paramValue.EMPTY_STRING);
      pl.append(p);
      
    otherwise
  end
  
end



