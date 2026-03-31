% spikecleaning detects and corrects possible spikes in analysis objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SPIKECLEANING detects spikes in the temperature data and
%	           replaces them by artificial values depending on the method
%              chosen ('random', 'mean', 'previous', 'linear', 'spline').
%              The first three methods consider extrapolation techniques
%              linear and spline apply interpolations to the data.
%
%	           Spikes are defined as singular samples or groups of samples
%              with an (absolute) value higher than kspike times the
%              standard deviation of the high-pass filtered (IIR filter)
%              input AO.x
%
% CALL:        b = spikecleaning(a1, a2, ..., an, pl)
%
% INPUTS:    aN - a list of analysis objects
%	           pl - parameter list
%
% OUTPUTS:     b - a list of analysis objects with "spike values" removed
%              and corrected
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'spikecleaning')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = spikecleaning(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  if nargout == 0
    error('### cat cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Apply defaults to plist
  pls = applyDefaults(getDefaultPlist, varargin{:});
  
  % initialise output array
  bs = [];
  
  % go through each input AO
  for ii = 1:numel(as)
    a = as(ii);
    d = a.data;
    
    % check this is a time-series object
    if ~isa(d, 'tsdata')
      error(' ### temperature spike detection requires tsdata (time-series) inputs.')
    end
    
    %--- check input parameters
    kspike = find_core(pls, 'kspike'); % kspike*sigma definition
    method = find_core(pls, 'method'); % method of spike-values substitution
    fc = find_core(pls, 'fc');
    order = find_core(pls, 'order');
    ripple = find_core(pls, 'ripple');
    numprevpoints = find_core(pls, 'numprevpoints');
    numfollpoints = find_core(pls, 'numfollpoints');
    interpoints = find_core(pls, 'interpoints');
    diffSpikes = find_core(pls, 'diffSpikes');
    times = find_core(pls, 'times');
    removeDDStemperatureOffset = find_core(pls, 'removeDDStemperatureOffset');
    offsetThreshold = find_core(pls, 'offsetThreshold');
    
    % Consolidate
    c = consolidate(a);
    a = c;
    
    % Initialise
    b = a;
    for kk = 1:times
      
      a = b;
      d = a.data;
      
      % high-pass filtering data
      filtplist = pls.subset('fc', 'order', 'ripple');
      filtplist.pset('gain', 1);          % gain of the filter
      filtplist.pset('type', 'highpass'); % type of the filter
      filtplist.pset('fs', d.fs);
      xfiltered = filtfilt(a, miir(filtplist));
      
      % standard deviation of the filtered data is calculated
      nxfiltered = y(abs(xfiltered) < kspike*std(xfiltered));
      xfiltered_2 = xfiltered.data.y(nxfiltered);
      
      std_xfiltered_2 = std(xfiltered_2);
      
      switch method
        
        case {'random', 'mean', 'previous'}
          
          % Get or set the random stream
          pls.getSetRandState();
          % spikes vector position is determined
          nspike = find(y(abs(xfiltered) > kspike*std_xfiltered_2));
          % substitution of spike values starts here
          xcleaned = a.data.y;
          
          for jj = 1:length(nspike)
            if nspike(jj) <=2 % just in case a spike is detected in the 1st or 2nd sample
              xcleaned(nspike(jj)) = mean(xcleaned(1:50));
            else
              if strcmp(method, 'random') % spike is substituted by a random value: N(0,std_xfiltered)
                xcleaned(nspike(jj)) = xcleaned(nspike(jj)-1) + randn(1)*std_xfiltered_2;
              elseif strcmp(method, 'mean') % spike is substituted by the mean if the two previous values
                xcleaned(nspike(jj)) = (xcleaned(nspike(jj)-1) + xcleaned(nspike(jj)-2))/2;
              elseif strcmp(method, 'previous') % spike is substituted by the previous value
                xcleaned(nspike(jj)) = xcleaned(nspike(jj)-1);
              end
            end
          end
          
          % make output analysis object
          b = ao(plist('xvals', a.x, 'yvals', xcleaned, ...
            'type', 'tsdata', 't0', a.t0, ...
            'yunits', a.yunits, ...
            'xunits', a.xunits));
          
        case {'linear', 'spline'}
          
          % 1st Diff
          a_diff = diff(a);%diff(diff(a));
          
          % Find all points out of threshold
          spikepoints = find(abs(a_diff.y) > kspike*std_xfiltered_2);
          %spikepoints = find(abs(xfiltered.y) > kspike*std_xfiltered_2);
          
          if isempty(spikepoints) || (spikepoints(1)==1) || (numel(spikepoints)>500) % case without spikes and very low kspike*std_xfiltered_2
            % Do nothing!   (a = a)
            b = a;
            
          else
            % Collect spikes (more than spikepoints can belong to the same spike!)
            startSpikeSample = [spikepoints(1)];
            for jj= 2:length(spikepoints)
              if  spikepoints(jj) - spikepoints(jj-1) >= diffSpikes % Detect if previous points were already 'spike points'
                startSpikeSample = [startSpikeSample, spikepoints(jj)];
              end
            end
            
            % Initialise auxiliar variables
            aux_x = [];
            aux_y = [];
            xlocation = [];
            
            % Loop for each detected spike
            for jj = 1:length(startSpikeSample)
              try
                % Prepare interp
                if (startSpikeSample(jj)-interpoints-numprevpoints < 1) || (startSpikeSample(jj)-interpoints < 1) || (startSpikeSample(jj)-numprevpoints < 1)
                  y_interpPRE{jj} = [a.y(1:startSpikeSample(jj)-numprevpoints)];
                  y_interpFOL{jj} = [a.y(startSpikeSample(jj)+numfollpoints:startSpikeSample(jj)+numfollpoints+interpoints)];
                  x_interpPRE{jj} = [a.x(1:startSpikeSample(jj)-numprevpoints)];
                  x_interpFOL{jj} = [a.x(startSpikeSample(jj)+numfollpoints:startSpikeSample(jj)+numfollpoints+interpoints)];
                else
                  
                  y_interpPRE{jj} = [a.y(startSpikeSample(jj)-numprevpoints-interpoints:startSpikeSample(jj)-numprevpoints)];
                  y_interpFOL{jj} = [a.y(startSpikeSample(jj)+numfollpoints:startSpikeSample(jj)+numfollpoints+interpoints)];
                  x_interpPRE{jj} = [a.x(startSpikeSample(jj)-numprevpoints-interpoints:startSpikeSample(jj)-numprevpoints)];
                  x_interpFOL{jj} = [a.x(startSpikeSample(jj)+numfollpoints:startSpikeSample(jj)+numfollpoints+interpoints)];
                  
                end
                
                ao_interpPRE(jj) = ao(plist('xvals', x_interpPRE{jj}, 'yvals', y_interpPRE{jj}, ...
                  'type', 'tsdata', 't0', a.t0));
                
                if (removeDDStemperatureOffset == 1)
                  % Project end point of the segment
                  incX = x_interpFOL{jj}(1) - x_interpPRE{jj}(end);
                  projVal = y_interpPRE{jj}(end) + ...
                    mean([diff(y_interpPRE{jj}); diff(y_interpFOL{jj})])*incX*a.fs;
                  
                  % Check if the continuing point is in the projection margin
                  if abs(abs(y_interpFOL{jj}(1)) - abs(projVal)) > offsetThreshold
                    
                    %If outside, modify ALL the following sequence
                    diffVal = projVal- y_interpFOL{jj}(1);
                    ao_interpFOL(jj) = ao(plist('xvals', x_interpFOL{jj}, ...
                      'yvals', y_interpFOL{jj} + diffVal, ...
                      'type', 'tsdata', 't0', a.t0));
                    
                    bb = ao(plist('xvals', a.x, ...
                      'yvals', [a.y(1:startSpikeSample(jj)+numfollpoints-1); ...
                      a.y(startSpikeSample(jj)+numfollpoints:end) + diffVal], ...
                      'type', 'tsdata', 't0', a.t0));
                    bb.setXunits(a.xunits);
                    bb.setYunits(a.yunits);
                    a = bb;
                    
                  else
                    ao_interpFOL(jj) = ao(plist('xvals', x_interpFOL{jj}, ...
                      'yvals', y_interpFOL{jj}, ...
                      'type', 'tsdata', 't0', a.t0));
                    
                  end
                  
                else
                  ao_interpFOL(jj) = ao(plist('xvals', x_interpFOL{jj}, ...
                    'yvals', y_interpFOL{jj}, ...
                    'type', 'tsdata', 't0', a.t0));
                  
                  
                end
                
                % Collect vector position of changed values for posterior replacement
                xlocation = [xlocation (startSpikeSample(jj) - numprevpoints):(startSpikeSample(jj) + numfollpoints)];
                
                % Define x points where to interpolate
                vertex = a.x((startSpikeSample(jj) - numprevpoints):(startSpikeSample(jj) + numfollpoints));
                
                ao_interp(jj) = join(ao_interpPRE(jj), ao_interpFOL(jj));
                
                % Call interp
                if jj>1
                  inter(jj) = interp(join(inter(jj-1), ao_interp(jj)), ...
                    plist('vertices', vertex, 'method', method));
                else
                  inter(jj) = interp(ao_interp(jj), plist('vertices', vertex, 'method', method));
                end
                
                aux_x = [aux_x inter(jj).x'];
                aux_y = [aux_y inter(jj).y'];
                
              catch
                warning(['Skipped spike ', num2str(jj), ' of ', num2str(length(startSpikeSample)), '. It may be too close to an ao edge.']);
              end
              
            end
            
            % Replace initial ao values with interpolated values
            new_y = a.y;
            for jj = 1:length(xlocation)
              new_y(xlocation(jj)) = aux_y(jj);
            end
            
            % Create new ao
            b = ao(plist('xvals', a.x, 'yvals', new_y', ...
              'type', 'tsdata', 't0', a.t0, ...
              'yunits', a.yunits));
          end
          
        otherwise
          error('Method not recognized. Please set it to random, mean, previous, spline or linear');
          
      end
      
      %%%%%%% join all methods here
      
    end
    
    b.setName(sprintf('spikecleaning(%s)', ao_invars{ii}));
    b.setXunits(a.xunits);
    b.setYunits(a.yunits);
    b.setT0(a.t0);
    b.setPlotinfo(a.plotinfo);
    
    % Add history
    if ~callerIsMethod
      b.addHistory(getInfo('None'), pls, ao_invars(ii), as(ii).hist);
    else
      % Spikecleaning creates always a complete new AO.
      % But for the case that this method is called by an other LTPDA
      % method should we keep the history of the input AO.
      b.setHist(as(ii).hist);
    end
    
    % add to output array
    bs = [bs b];
    
  end
  
  % Keep the shape of the input objects
  bs = reshape(bs, size(as));
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  
  pl = plist();
  
  % kspike
  p = param({'kspike', 'High values imply no correction of relative low amplitude spikes.'}, paramValue.DOUBLE_VALUE(3.3));
  pl.append(p);
  
  % fc
  p = param({'fc', 'Frequency cut-off of the IIR filter.'}, paramValue.DOUBLE_VALUE(0.025));
  pl.append(p);
  
  % Order
  p = param({'order', 'The order of the IIR filter.'}, paramValue.DOUBLE_VALUE(2));
  pl.append(p);
  
  % Ripple
  p = param({'ripple', 'Specify the pass/stop-band ripple for bandpass/bandreject filters'}, ...
    paramValue.DOUBLE_VALUE(0.5));
  pl.append(p);
  
  % Method
  p = param({'method', 'The method used to replace the spike value. Random and mean follow extrapolation methods while spline and linear follow interpolateion methods.'}, {1, {'random', 'mean', 'previous', 'spline', 'linear'}, paramValue.SINGLE});
  pl.append(p);
  
  % Numprevpoints
  p = param({'numprevpoints', 'Number of previous points to delete and interpolate.'}, paramValue.DOUBLE_VALUE(4));
  pl.append(p);
  
  % Numfollpoints
  p = param({'numfollpoints', 'Number of following points to delete and interpolate.'}, paramValue.DOUBLE_VALUE(5));
  pl.append(p);
  
  % interpoints
  p = param({'interpoints', 'Length of the segments at both sides of the spike that are going to be used when interpolating.'}, paramValue.DOUBLE_VALUE(10));
  pl.append(p);
  
  % diffSpikes
  p = param({'diffSpikes', 'Minimum distance in samples between spikes to consider them different spikes.'}, paramValue.DOUBLE_VALUE(6));
  pl.append(p);
  
  % times
  p = param({'times', 'Number of times to clean the spikes recursively.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  % removeDDStemperatureOffset
  p = param({'removeDDStemperatureOffset', 'Remove DDS temperature offset after scale change tranitory'}, {1,{0, 1},paramValue.OPTIONAL});
  pl.append(p);
  
  % offsetThreshold
  p = param({'offsetThreshold', 'Offset threshold when removing the DDS temperature offset after scale change (only if selected).'}, paramValue.DOUBLE_VALUE(0.001));
  pl.append(p);
  
  % RAND_STREAM
  pl.append(copy(plist.RAND_STREAM, 1));
end

