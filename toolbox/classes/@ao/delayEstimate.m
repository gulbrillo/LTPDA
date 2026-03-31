% DELAYESTIMATE estimates the delay between two AOs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DELAYESTIMATE returns an estimate of the delay between the two
%              input analysis objects. Different weights in frequency
%              domain can be used.
%
% CALL:        bs = delayEstimate(a1,a2,pl)
%
% INPUTS:      a1    - input analysis objects
%              a2    - delayed analysis objects
%              pl    - input parameter list
%
% OUTPUTS:     bs    - analysis object with the delay (as cdata)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'delayEstimate')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = delayEstimate(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % get frequency weight
  weight = find_core(pl, 'weight');
  
  N = len(bs(1));
  T = bs(1).x(end);
  fs = bs(1).fs;
  % zeropad to avoid circular convolution in ifft
  bs(1).zeropad;
  bs(2).zeropad;
  % compute spectral density, scale applied after to avoid round-off errors
  scale = fs/N;
  Gx11 = conj(fft(bs(1).y)).*fft(bs(1).y);
  Gx11 = Gx11*scale;
  Gx12 = conj(fft(bs(1).y)).*fft(bs(2).y);
  Gx12 = Gx12*scale;
  Gx22 = conj(fft(bs(2).y)).*fft(bs(2).y);
  Gx22 = Gx22*scale;
  % frequencies for two-sided spectrum
  f = linspace(-fs,fs,2*N);
  % select weight
  if strcmp(weight,'roth')
    weight = Gx11;
  elseif strcmp(weight,'scot')
    weight = sqrt(Gx11.* Gx22);
  elseif strcmp(weight,'scc')
    weight = 1;
  elseif strcmp(weight,'phat')
    weight = abs(Gx12);
  elseif strcmp(weight,'eckart')
    weight = 1;
  elseif strcmp(weight,'ML')
    weight = 1;
  else
    error('###  Unknown value for ''weight'' parameter '  )
  end
  % compute unscaled correlation function
  Ru = ifft(Gx12./weight);
  % lag= 0:\deltat*(N-1)
  % n= 1:N/2-1
  r = linspace(0,T-1/fs,length(Ru)/2-1);
  % scaling to correct zeropad bias
  R = (N./(N-r))'.*Ru(1:length(Ru)/2-1);
  % get maximum
  [m,ind] = max(R);
  del = r(ind);
  % plot if required
  plt = find_core(pl, 'plot');
  if plt
    Rxy = ao(xydata(r,R));
    Rxy.setName(sprintf('Correlation(%s,%s)', ao_invars{1},ao_invars{2}))
    iplot(Rxy)
  end
  
  % create new output cdata
  cd = cdata(del);
  % add unitss
  cd.setYunits(unit.seconds);
  % update AO
  c = ao(cd);
  % Add name
  c.name = sprintf('delayEst(%s,%s)', ao_invars{1},ao_invars{2});
  % Add history
  c.addHistory(getInfo('None'), pl, [ao_invars(:)], [bs(:).hist]);
  
  % set output
  varargout{1} = c;
  
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist();
  % method
  p = param({'weight',['scaling of output. Choose from:<ul>', ...
    '<li>scc  - </li>', ...
    '<li>roth  - </li>', ...
    '<li>scot  - </li>', ...
    '<li>phat  - </li>', ...
    '<li>eckart  - </li>', ...
    '<li>ML - </li></ul>']}, {1, {'scc','roth', 'scot','phat','eckart','ML'}, paramValue.SINGLE});
  pl.append(p);
  % Plot
  p = param({'Plot', 'Plot the correlation function'}, ...
    {2, {'true', 'false'}, paramValue.SINGLE});
  pl.append(p);
end
% END

