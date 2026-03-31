% FILTFILT overrides the filtfilt function for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FILTFILT overrides the filtfilt function for analysis objects.
%              Applies the input digital IIR filter to the input analysis object
%              forwards and backwards. If the input analysis object contains a
%              time-series (tsdata) then the filter is applied using the normal
%              recursion algorithm. The output analysis object contains a tsdata
%              object.
%
%              If the input analysis object contains a frequency-series (fsdata)
%              then the response of the filter is computed and then multiplied
%              with the input frequency series. The output analysis object
%              contains a frequency series.
%
% CALL:        >> b = filtfilt(a,pl)
%
% INPUTS:      pl   - a parameter list
%              a    - input analysis object
%
% OUTPUTS:
%              b    - output analysis object containing the filtered data.
%
% PROCINFO:    The input filter object with the history values filled in are
%              always stored with a plist in the 'procinfo' property of the AO.
%              The key of the plist to get the filter is 'FILTER'.
% 
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'filtfilt')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = filtfilt(varargin)
  
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
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pl, pl_invars] = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  [fbobjs, f_invars] = utils.helper.collect_objects(varargin(:), 'filterbank', in_names);
  [fobj, f_invars] = utils.helper.collect_objects(varargin(:), 'ltpda_filter', in_names);
  
  % Make copies or handles to inputs
  bs   = copy(as, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  
  if isempty(fobj) && isempty(fbobjs)
    fobj        = find_core(pl, 'filter');
    if isa(fobj, 'filterbank')
    fbobjs = fobj;
    end
    f_invars{1} = class(fobj);
  end
  
  % check inputs
  if ~isa(fobj, 'miir') && ~isa(fobj, 'mfir') && ~isa(fbobjs, 'filterbank')
    error('### the filter input should be either an miir/mfir object or a filterbank object.');
  end
  
  fobj_out = [];
  fp = [];
  
  % Loop over AOs
  for jj = 1:numel(bs)
    
    % Copy filter so we can change it
    if ~isempty(fobj)
      fp = copy(fobj, 1);
    elseif ~isempty(fbobjs)
      fp = copy(fbobjs, 1);
    end
    % keep the history to suppress the history of the intermediate steps
    inhist = bs(jj).hist;
    
    if isa(bs(jj).data, 'tsdata')
      %------------------------------------------------------------------------
      %------------------------   Time-series filter   ------------------------
      %------------------------------------------------------------------------
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%     filter    %%%%%%%%%%%%%%%%%%%%%%%%%%%
      if isa(fp,'ltpda_filter')
        % redesign if needed
        fs = bs(jj).data.fs;
        if fs ~= fp.fs 
          warning('!!! Filter is designed for a different sample rate of data.');
          % Adjust/redesign if this is a standard filter
          fp = redesign(fp, fs);
        end
        % apply filter
        y = bs(jj).data.y;
        y_cl = class(y);
        if strcmpi(y_cl, 'double')
          if isa(fp, 'miir')
            bs(jj).data.setY(filtfilt(fp.a, fp.b, y));
          elseif isa(fp, 'mfir');
            bs(jj).data.setY(filtfilt(fp.a, 1, y));
          else
            error('### Unknown filter object [%s]', class(fp));
          end
        else
          warning('### Data of class [%s] will not be filtered', y_cl);
        end
        % set y-units = yunits.*ounits./iunits
        bs(jj).data.setYunits(bs(jj).data.yunits.*fp.ounits./fp.iunits);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%     filter bank     %%%%%%%%%%%%%%%%%%%%%%%%%%%
      elseif isa(fp,'filterbank')
        % redesign not implemented for filterbank
        %%%
        % utils.math routine to apply filtfilt properly
        bs(jj).data.setY(utils.math.filtfilt_filterbank(bs(jj),fp));
        % not setting units yet
        %%%
      end
      
    elseif isa(bs(jj).data, 'fsdata')
      %------------------------------------------------------------------------
      %----------------------   Frequency-series filter   ---------------------
      %------------------------------------------------------------------------
      
      % apply filter
      fil_resp = resp(fp, plist('f', bs(jj)));
      bs(jj)    = bs(jj).*fil_resp.*conj(fil_resp);
    else
      error('### unknown data type.');
    end
    
    
    % name for this object
    bs(jj).name = sprintf('%s(%s)', fp.name, ao_invars{jj});
    % add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), [inhist fp.hist]);
    % clear errors
    bs(jj).clearErrors;
    % Store the filter in the procinfo
    bs(jj).procinfo = plist('filter', fp);
  end
  
  % Set outputs
  varargout = utils.helper.setoutputs(nargout, bs);
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
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
  pl = plist({'filter', 'The filter to apply to the data.'},  paramValue.EMPTY_STRING);
end


