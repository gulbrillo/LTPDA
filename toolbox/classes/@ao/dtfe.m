% DTFE estimates transfer function between time-series objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DTFE makes discrete transfer function estimates of the time-series
%              in the input analysis objects. The estimate is done by taking
%              the ratio of the DFTs between the two inputs at the
%              specified frequencies.
%
% CALL:        b = dtfe(a1,a2,pl)
%
% INPUTS:      a1   - input analysis object
%              a2   - input analysis object
%              pl   - input parameter list
%
% OUTPUTS:     b    - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'dtfe')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = dtfe(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  if nargout == 0
    error('### dtfe cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Throw an error if input is not two AOs
  if numel(as) ~= 2
    error('### tfe only accepts two inputs AOs.');
  end
  
  tsao = [];
  tsinvars = {};
  for ll = 1:numel(as)
    if isa(as(ll).data, 'tsdata')
      tsao = [tsao as(ll)];
      tsinvars = [tsinvars ao_invars(ll)];
    else
      warning('### xspec requires tsdata (time-series) inputs. Skipping AO %s. \nREMARK: The output doesn''t contain this AO', invars{ll});
    end
  end
  
  %----------------- Gather the input history objects
  inhists = [tsao(:).hist];
  
  %----------------- Check the time range
  time_range = mfind(pl, 'split', 'times');
  for ll = 1:numel(tsao)
    if ~isempty(time_range)
      switch class(time_range)
        case 'double'
          tsao(ll) = split(tsao(ll), plist(...
            'times', time_range));
        case 'timespan'
          tsao(ll) = split(tsao(ll), plist(...
            'timespan', time_range));
        case 'time'
          tsao(ll) = split(tsao(ll), plist(...
            'start_time', time_range(1), ...
            'end_time', time_range(2)));
        case 'cell'
          tsao(ll) = split(tsao(ll), plist(...
            'start_time', time_range{1}, ...
            'end_time', time_range{2}));
        otherwise
      end
    end
    if numel(tsao(ll).data.y) <= 0
      error('### I found no data in the selected time-range. Either the %d-th object is empty, or you need to revise your settings ...', ll);
    end
  end
  
  % detrend
  detrendOrder = find_core(pl, 'order');
  tsao = detrend(tsao, plist('order', detrendOrder));
  
  % process each object
  dftpl = pl.subset(ao.getInfo('dft').plists.getKeys);
  
  for jj=1:numel(tsao)
    
    
    % Process the parameters in the loop because the data can be different
    % lengths
    usepl = utils.helper.process_spectral_options(pl, 'lin', tsao(jj).len);
    
    win          = find_core(usepl, 'Win');
    winVals      = win.win.'; % because we always get a column from ao.y
        
    win = ao(plist('vals', winVals));
    dft_data(jj) = dft(win.*tsao(jj), dftpl);    
  end
  
  % Compute transfer function with dft
  

  % An alternative which I tried for better error estimates... but it
  % doesn't seem to be better
  % re = real(dft_data);
  % im = imag(dft_data);
  % T = (re(2).*re(1)+ 1i.*(im(2).*re(1)-re(2).*im(1))) ./ ( re(1).^2 + im(1).^2 );
   
  T = dft_data(2) ./ dft_data(1);
  
  % prepare output object
  T.name = sprintf('dtfe(%s->%s)', tsinvars{1}, tsinvars{2});
  T.addHistory(getInfo(), pl, [tsinvars(:)], inhists);
    
  % Propagate 'plotinfo'
  if isempty(tsao(1).plotinfo)
    if ~isempty(tsao(2).plotinfo)
      T.plotinfo = copy(tsao(2).plotinfo, 1);
    end
  else
    T.plotinfo = copy(tsao(1).plotinfo, 1);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, T);
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(2);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = copy(ao.getInfo('dft').plists);
  pl = combine(pl);
  
  % Set the default window to the window in the preferences
  pl.setDefaultForParam('win', LTPDAprefs.default_window);
  
  % Order, N
  p = param({'Order',['The order of segment detrending:<ul>', ...
    '<li>-1 - no detrending</li>', ...
    '<li>0 - subtract mean</li>', ...
    '<li>1 - subtract linear fit</li>', ...
    '<li>N - subtract fit of polynomial, order N</li></ul>']}, paramValue.DETREND_ORDER);
  p.val.setValIndex(2);
  p.addAlternativeKey('N');
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
  
end

% END
