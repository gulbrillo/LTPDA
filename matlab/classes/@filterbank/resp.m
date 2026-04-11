% RESP Make a frequency response of a filterbank.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESP Make a frequency response of a filter bank.
%              The input filter should be a filterbank object.
%
%              The response is returned as a frequency-series in an
%              analysis object.
%
% CALL:        as = resp(filts1,filts2,...,pl)
%              as = resp(filts,pl)
%              as = filts.resp(pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('filterbank', 'resp')">Parameters Description</a>
%
% INPUTS:      filtsN   - input filterbank objects
%              filts    - input filterbank objects array
%              pl       - input parameter list
%
% OUTPUTS:     as       - array of analysis objects, one for each input
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = resp(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  %%% get input filter
  [filts, filt_invars] = utils.helper.collect_objects(varargin(:), 'filterbank', in_names);
  pl                   = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  if isempty(pl)
    pl = plist;
  end
  
  cs = ao.initObjectWithSize(size(filts, 1), size(filts, 2));
  
  % Go through each input AO
  for jj = 1 : numel(filts)
    % make output analysis object
    cs(jj) = resp(filts(jj).filters, pl.pset('bank',filts(jj).type));
    % set name
    cs(jj).name = sprintf('resp(%s)', filt_invars{jj});
    % Add history
    cs(jj).addHistory(getInfo('None'), pl, filt_invars(jj), filts(jj).hist);
  end
  
  % Outputs
  if nargout == 0
    iplot(cs)
  elseif nargout == numel(cs)
    % List of outputs
    for ii = 1:numel(filts)
      varargout{ii} = cs(ii);
    end
  else
    % Single output
    varargout{1} = cs;
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)

  ii = ltpda_filter.getInfo('resp', varargin{:});
  ii.setMclass('filterbank');
  % The 'bank' parameter is overriden by the filterbank type
  if ~strcmpi(varargin{1}, 'None')
    ii.plists.remove('bank');
  end
end



