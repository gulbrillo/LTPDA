% CGFILL fills specified gaps in the data given an inital guess for the spectrum.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CGFILL fills specified gaps in the data given an
%              inital guess for the spectrum using the constrained gaussian
%              method. At present, it only fits data described by a
%              piecewise power-law spectrum
%
%
% CALL:        out = obj.cgfill(pl)
%              out = cgfill(objs, pl)
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input ao object(s)
%
% OUTPUTS:     out - filled data series.
%
%
% Created 2013-02-20, M Hewitson
%     - adapted from code writen by Curt Cutler and Ira Thorpe.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'cgfill')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cgfill(varargin)
  
  % Determine if the caller is a method or a user
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Print a run-time message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names for storing in the history
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all objects of class ao
  [objScale, obj_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  %--- Decide on a deep copy or a modify.
  % If the no output arguments are specified, then we are modifying the
  % input objects. If output arguments are specified (nargout>0) then we
  % make a deep copy of the input objects and return modified versions of
  % those copies.
  objsCopy = copy(objScale, nargout);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % general parameters
  mode     = pl.find('mode');
  Niter    = pl.find('Niter');
  gapIdx   = pl.find('indices');
  sflag    = pl.find('sub_flag');
  segLen   = pl.find('seglen');
  oLapFrac = pl.find('olap');
  
  % spectral fitting parameters
  winType = pl.find('win');
  lambda = pl.find('orders');
  offsets = pl.find('offsets');
  P(1,:) = double(pl.find('p0'));
  w = pl.find('weights');
  
  % gap-filling parameters
  Npts = pl.find('samples');
  
  % debugging flag
  DEBUG_FLAG = pl.find('DEBUG');
  
  % build spectral estimation plists
  psdpl = plist('scale','PSD','win', winType, 'navs', 1, 'order', 1);
  
  % Loop over input objects
  out = [];
  for jj = 1 : numel(objsCopy)
    % Process object jj
    object = objsCopy(jj);
    
    % check the data
    if ~isa(object.data, 'tsdata')
      warning('Skipping input object [%s] - it is not a time-series', objScale.name);
      continue;
    end
    
    % scale data to have an RMS of 1
    % not sure if this is really necessary
    [objScale, P, scaleFactor] = scaleData(object, P);
    
    % initial estimate for timeseries (fill with straight lines)
    yfill = subsData(objScale, plist('indices', gapIdx, 'sub_flag',sflag,'mode', 'Line'));
    yfill.setName(['gap[',objScale.name,']']);
    
    % iterate over fill runs
    for kk=1:Niter
      
      utils.helper.msg(msg.PROC1, 'Input %d: iteration %d', jj, kk);
      
      % compute segment indices
      [segIndices, nSegs, oLapAdj] = generateSegmentIndices(yfill.len(), oLapFrac, segLen);
      utils.helper.msg(msg.PROC1, 'Number of segments: %d, segment overlap: %0.2f%%', nSegs, 100*oLapAdj/segLen);
      
      % create a pulse train from the edges
      if isempty(sflag) && ~isempty(gapIdx)
        pulses = ao(plist('built-in', 'pulsetrain', 'edges', gapIdx, 'nsecs', yfill.nsecs, 'fs', yfill.fs));
      elseif ~isempty(sflag) && isempty(gapIdx)
        pulses = sflag;
      else
        error('gap indicies and subsitution flag cannot be simultaneously specified');
      end
      
      
      % NOTE: do we just ignore the 'samples' parameter now? If not, how do
      % we deal with it?
      
      % prepare the segments for filling
      if ~isempty(segLen)
        yfill  = split(yfill, plist('samples', segIndices));
        pulses = split(pulses, plist('samples', segIndices));
      else
        % what do we do in this case?
      end
      
      % build model, if needed
      if kk==1
        [Smod, CTF, pepl, fillFit] = buildModel(yfill(1), P, lambda, offsets, pl, psdpl.pset('nfft', segLen));
      end
      
      % compute iacf
      Cli(kk) = Smod.iacf(plist('SAMPLES', Smod.len-1));
      
      % iterate over the data segments for this fill run
      for ss=1:numel(yfill)
        
        % get the gap indexes for this segment
        segGaps = pulses(ss).edgedetect();
        
        % debugging
        if DEBUG_FLAG
          Syfill   = yfill(ss).psd(psdpl);
          y(ss)    = copy(yfill(ss), 1);
          Sy(ss)   = copy(Syfill, 1);
          yfit(ss) = copy(fillFit, 1);
          ymod(ss) = copy(Smod, 1);
          iplot(y)
          iplot(find(Sy, ymod, plist('QUERY', 'x>0')))
        end
        
        % Fill gaps, if there are any
        if len(segGaps) > 1
          yfill(ss) = subsData(yfill(ss), plist(...
            'mode', 'Constrained Gaussian',...
            'indices', segGaps,...
            'IACF', Cli(kk), 'seed', pl.find('seed')));
          
          pl.pset('seed', yfill(ss).procinfo.find('seed'));
        end
      end
      
      % rejoin the 'central' segments
      yfill = joinSegments(yfill, objScale, oLapAdj, DEBUG_FLAG);
      
      % take spectrum
      Syfill(kk) = yfill.psd(psdpl.pset('nfft', segLen));
      
      % spectrum corrected by pre-filter
      Sc = Syfill(kk)./CTF;
      
      % fit filled spectrum
      fillFit = powerFit(Sc.find('x<0.1'), plist(...
        'orders',lambda,...
        'P0',P(kk,:),...
        'LB',P(kk,:).*(0.001*ones(size(P(kk,:)))),...
        'UB',P(kk,:).*(1000*ones(size(P(kk,:)))),...
        'OFFSETS',offsets,...
        'Function','Sum'));
      
      % copy best-fit parameters
      P(kk+1,:) = fillFit.y';
      
      % eval fit to get spectrum
      Smod = fillFit.eval(pepl).*CTF;
      Smod.setName(['Fit(' Syfill(kk).name ')']);
      
    end % End iteration loop
    
    % undo scaling
    
    % timeseries
    objOut = yfill.*scaleFactor;
    objOut.setName(sprintf('cgfill(%s)', obj_invars{jj}));
    
    % parameters
    for kk = 1:size(P,1)
      P(kk,:) = P(kk,:)*(scaleFactor.y.^2);
    end
    
    % fillFit
    fitOut = copy(fillFit,1);
    modOut = fitOut.models;
    modOut.setValues(num2cell(cell2mat(modOut.values)*scaleFactor.y^2))
    modOut.setYunits(modOut.yunits*(scaleFactor.yunits).^2);
    fitOut.setModels(modOut);
    fitOut.setY(P(end,:));
    Pyunits = fitOut.yunits;
    for ii = 1:numel(Pyunits)
      Pyunits(ii) = Pyunits(ii)*(scaleFactor.yunits.^2);
    end
    fitOut.setYunits(Pyunits);
    fitOut.setName(sprintf('powerFit(cgfill(%s))',obj_invars{jj}));
    
    % model output
    Smod = Smod.*(scaleFactor.^2);
    Smod.simplifyYunits();
    Smod.setName(sprintf('eval(powerFit(cgfill(%s)))',obj_invars{jj}));
    
    % Set output object properties
    if ~isempty(object.plotinfo)
      objOut.plotinfo = copy(object.plotinfo, 1);
    end
    
    
    if ~callerIsMethod
      
      % add history
      objOut.addHistory(getInfo('None'), pl,  obj_invars(jj), object.hist);
      
      % build proc info
      pinfo = plist();
      
      % amplitudes (including progression)
      p = param('amplitudes',P);
      pinfo.append(p);
      
      % final model
      p = param('Spectral Fit',fitOut);
      pinfo.append(p);
      
      % IACF
      p = param('IACF',Cli);
      pinfo.append(p);
      
      % if debugging dump everything into proc_info
      if DEBUG_FLAG
        p = param('y',y);
        pinfo.append(p);
        
        p = param('Sy',Sy);
        pinfo.append(p);
        
        p = param('yfit',yfit);
        pinfo.append(p);
        
        p = param('ymod',ymod);
        pinfo.append(p);
        
        p = param('scaleFactor',scaleFactor);
        pinfo.append(p);
        
      end
      % set proc info
      objOut.setProcinfo(pinfo);
    end
    
    % store output
    out = [out objOut];
    
  end % loop over analysis objects
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
end

function [segIndices, nSegs, oLapAdj] = generateSegmentIndices(L, oLapFrac, segLen)
  
  oLap     = round(oLapFrac * segLen / 100);
  nSegs    = floor((L - oLap)./(segLen - oLap));
  if nSegs == 1
    % If we can only do 1 segment, then treat the full data set.
    oLapAdj = 0;
    segIndices = [1 L];
  else
    oLapAdj  = 2*ceil((L - nSegs * segLen)./(1-nSegs)./2);
    segmentStep   = segLen - oLapAdj;
    segmentStarts = 1:segmentStep:nSegs*segmentStep;
    segmentEnds   = segmentStarts + segLen - 1;
    segIndices    = reshape([segmentStarts;segmentEnds], 1, []);
  end
end

function yfill = joinSegments(yfill, objScale, oLapAdj, DEBUG_FLAG)
  
  if DEBUG_FLAG
    % plot segments with offsets to aid visualisation
    for ss=1:numel(yfill)
      yp(ss) = yfill(ss) + ss;
    end
    iplot(yp);
  end
  
  % do first segment
  yfill(1) = split(yfill(1), plist('offsets', objScale.fs * [0 -oLapAdj/2]));
  
  % mid segments
  yfill(2:end-1) = split(yfill(2:end-1), plist('offsets', objScale.fs * [oLapAdj/2 -oLapAdj/2]));
  
  % last segment
  yfill(end) = split(yfill(end), plist('offsets', objScale.fs * [oLapAdj/2 0]));
  
  if DEBUG_FLAG
    % plot the segments we will join up
    for ss=1:numel(yfill)
      yp(ss) = yfill(ss) + ss;
    end
    iplot(yp);
  end
  
  yfill = join(yfill, objScale);
  
  if DEBUG_FLAG
    % plot the joined up data
    iplot(yfill);
  end
end

function [Smod, CTF, pepl, fillFit] = buildModel(objScale, P, lambda, offsets, pl, psdpl)
  
  % spectrum of initial guess
  Syfill = objScale.psd(psdpl);
  
  % build initial guess a pest (should we be able to pass a pest?)
  xunits = unit('Hz');
  yunits = objScale.yunits * unit('Hz^-1');
  model = [];
  for kk = 1:length(lambda)
    if kk == 1
      model = [model 'P' num2str(kk) '*(X+' num2str(offsets(kk)), ').^(' num2str(lambda(kk)) ')'];
    else
      model = [model ' + P' num2str(kk) '*(X+' num2str(offsets(kk)), ').^(' num2str(lambda(kk)) ')'];
    end
    units(kk) = simplify(yunits/xunits.^(lambda(kk)));
    names{kk} = ['P' num2str(kk)];
  end
  
  model = smodel(plist('expression', model, ...
    'params', names, ...
    'values', P(1,:), ...
    'xvar', 'X', ...
    'xunits', xunits, ...
    'yunits', yunits ...
    ));
  
  % Build the output pest object
  fillFit = pest;
  fillFit.setY(P(1,:));
  fillFit.setNames(names{:});
  fillFit.setYunits(units);
  fillFit.setModels(model);
  
  % build pre-filter
  preFilt = pl.find('PRE_FILTER');
  if ~isempty(preFilt)
    switch class(preFilt)
      case 'double'
        if numel(preFilt) ~= numel(Syfill.x)
          error('pre-filter length does not match expected length');
        end
        CTF = ao(fsdata(Syfill.x, preFilt));
        CTF.setXunits('Hz');
        CTF.setName('CTF');
      case 'ao'
        if numel(preFilt.y) ~= numel(Syfill.y)
          error('pre-filter length does not match data length');
        elseif max(abs(preFilt.x-Syfill.x))~= 0
          error('pre-filter x-values do not match those of data');
        end
        CTF = preFilt;
      case 'plist'
        if isempty(preFilt.find('built-in'))
          error('pre-filt plist must be a built-in AO model')
        end
        % copy object x-values to appropriate place in model
        preFilt.append(param(pl.find('X_VAR'),Syfill.x));
        % build model to get correction transfer function
        CTF = ao(preFilt);
      otherwise
        error('pre-filter must be a double, AO, or plist');
    end
  else
    CTF = 1;
  end
  
  % evaluate initial guess to make spectral model, including
  % non-power-law component
  pepl = plist('xdata',Syfill,'xfield','x');
  Smod = fillFit.eval(pepl).*CTF;
  
end


function [objScale, P, scaleFactor] = scaleData(object, P)
  rms = sqrt(mean((object.y-mean(object.y)).^2));
  scaleFactor = ao(cdata(rms));
  scaleFactor.setYunits(object.yunits);
  objScale = object./scaleFactor;
  objScale.simplifyYunits();
  objScale.setName('y');
  
  % scale the initial guess for power-law amplitudes
  P(1,:) = P(1,:)/(scaleFactor.y^2);
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
  
  % Create empty plsit
  pl = plist();
  
  % psd params
  pl.append(subset(ao.getInfo('psd').plists,'WIN'));
  
  % powerFit params
  pl.append(subset(ao.getInfo('powerFit').plists,{'orders','p0','offsets','weights'}));
  
  % subsData params: indices
  pl.append(subset(ao.getInfo('subsData', 'Constrained Gaussian').plists, {'indices', 'sub_flag', 'Seed'}));
  
  % iacf params: samples
  pl.append(subset(ao.getInfo('iacf', 'Default').plists, {'samples'}));
  
  % Niter
  p = param(...
    {'NIter','The number of iterations to perform for the ''iterate'' mode.'},...
    paramValue.DOUBLE_VALUE(1));
  p.addAlternativeKey('iterations');
  pl.append(p);
  
  % Mode
  p = param(...
    {'Mode',['The method for deciding when to end the filling procedure:<ul>'...
    '<li>iterate - Run the procedure N times then stop</li>', ...
    '</ul>']},...
    {1, {'iterate'}, paramValue.SINGLE});
  pl.append(p);
  
  % Pre-filter
  p = param({'PRE_FILTER', ['Filter applied to data (multiplicaiton) before fitting to correct for non-powerlaw behavior in PSD.'...
    'Can either be an AO, an array, or a plist for a built-in AO model']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % seg length
  p = param({'seglen', 'Specify the length of segments (in seconds) to fill individually on each iteration. If left empty, the full data will be filled each time. Note: if this parameter is specified, the ''SAMPLES'' parameter is ignored and the correlation function is computed for the full length of each individual segment.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % olap
  p = param({'olap', 'Target overlap fraction (%). This may be adjusted slightly internally to better fit the segments to the full input data.'}, paramValue.DOUBLE_VALUE(50));
  pl.append(p);
  
  % X_VAR
  p = param({'X_VAR', 'Key value for dependant variable for the case in which PRE_FILTER is a plist for a built-in AO model'},'F');
  pl.append(p);
  
  % DEBUG
  p = param({'DEBUG', 'Set to true to put additional objects into procinfo'},paramValue.FALSE_TRUE);
  pl.append(p);
  
  
end

% END
