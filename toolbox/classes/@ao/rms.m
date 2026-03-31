% RMS Calculate RMS deviation from spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RMS Calculate RMS deviation from spectrum
%
% CALL:        b = rms(a)
%
% INPUTS:      a  - input analysis object containing spectrum
%
% OUTPUTS:     b  - analysis object containing RMS deviation
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'rms')">Parameters Description</a>
%
% NOTE:        Taken from code by: 1998.05.25      Masaki Ando
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rms(varargin)

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

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Loop over input AOs
  for jj = 1:numel(bs)
    % check input data
    if isa(bs(jj).data, 'fsdata')
      % get data
      f = bs(jj).data.getX;
      spe = [f bs(jj).data.getY];
      % start and end frequencies
      s = f(1);
      e = f(end);
      % compute integrated rms
      l1 = spe(:,1) >= s;
      sp = spe(l1,:);
      l2 = sp(:,1) <= e;
      sp = sp(l2,:);
      si = size(sp);
      li = si(1,1);
      freq = sp(:,1);
      sp2 = sp(:,2).^2;
      ms = sp2;
      for i = li-1 :-1: 1
        ms(i) = ms(i+1)+(sp2(i+1)+sp2(i))*(freq(i+1)-freq(i))/2;
      end
      % set data
      bs(jj).data.setXY(freq, sqrt(ms));
      % set name
      bs(jj).name = sprintf('RMS(%s)', ao_invars{jj});
      % Add history
      bs(jj).addHistory(getInfo('None'), plist, ao_invars(jj), bs(jj).hist);
      % clear errors
      bs(jj).clearErrors;
    else
      warning('!!! Skipping AO %s - it''s not an frequency series.', ao_invars{jj});
    end
  end

  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end
% END

