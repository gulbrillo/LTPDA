% REDESIGN redesign the input filter to work for the given sample rate.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: REDESIGN redesign the input filter to work for the given sample
%              rate.
%
% CALL:        filt = redesign(filt, fs)
%              filt = redesign(filt, plist-object)
%
% INPUT:       filt - input (mfir) filter
%              fs   - new sample rate
%
% OUTPUT:      filt - new output filter
%
% <a href="matlab:utils.helper.displayMethodInfo('mfir', 'redesign')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = redesign(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.OMNAME, 'running %s/%s', mfilename('class'), mfilename);
  
  %%% check numer of outputs
  if nargout == 0
    error('### cat cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [filt, filt_invars, rest] = utils.helper.collect_objects(varargin(:), 'mfir', in_names);
  pls = utils.helper.collect_objects(rest(:), 'plist');
  
  %%% Combine input plists
  pls = applyDefaults(getDefaultPlist(), pls);
  
  %%% Get 'fs' from the second input or from the input plist
  if numel(rest) == 1 && isnumeric(rest{1})
    fs = rest{1};
    pls.pset('fs', fs);
  elseif pls.nparams == 1 && pls.isparam_core('fs')
    fs = pls.find_core('fs');
  else
    error('### Please specify the new sample rate.');
  end
  
  %%% Redesing all filters
  for kk = 1:numel(filt)
    utils.helper.msg(msg.OPROC1, 're-designing filter for fs=%2.2f Hz...', fs);
    
    % Get the plistUsed from the constructor block (not from a copy constructor).
    h  = filt(kk).hist;
    lc = 1;
    while lc<100
      if ~strcmp(h.methodInfo.mcategory, utils.const.categories.constructor)
        % Not a constructor block
      else
        % Copy constructor or a 'normal' constructor
        if ~isempty(h.plistUsed) && (h.plistUsed.nparams > 0)
          % Leave the loop if 'plistUsed' is filled -> Not a copy constructor
          break;
        end
      end
      if ~isempty(h.inhists)
        h = h.inhists(1);
      end
      lc = lc + 1;
    end
    % Throw an error if no constructor block is found.
    if ~strcmp(h.methodInfo.mcategory, utils.const.categories.constructor)
      error('### Found no constructor block to get the plistUsed.');
    end
    
    fpl  = h.plistUsed;
    type = find_core(fpl, 'type');
    pzm  = find_core(fpl, 'pzmodel');
    
    % retain the following properties of the miir object and set them at the end
    % of the method.
    name   = filt(kk).name;
    iunits = filt(kk).iunits;
    ounits = filt(kk).ounits;
    hist   = filt(kk).hist;
    
    if  strcmpi(type, 'highpass') ||...
        strcmpi(type, 'lowpass')  ||...
        strcmpi(type, 'bandpass') ||...
        strcmpi(type, 'bandreject')
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%                 From Standard types                 %%%%%%%%%%
      
      utils.helper.msg(msg.OPROC2, 're-designing standard filter.');
      try
        fpl = pset(fpl, 'fs', fs);
        utils.helper.msg(msg.OPROC2, 'setting new fs.');
      catch
        fpl = append(fpl, 'fs', fs);
        utils.helper.msg(msg.OPROC2, 'appending parameter fs.');
      end
      filt(kk) = mfir(fpl);
      
    elseif ~isempty(pzm)
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%                 From pole/zero model                 %%%%%%%%%
      
      % REMARK: Only the history of ltpda_uoh objects are stroed in a plist and
      %         not the object itself.
      %         We have to rebuild the object to get the object back.
      if isa(pzm, 'history')
        pzm = rebuild(pzm);
      end
      utils.helper.msg(msg.OPROC2, 're-designing pzmodel filter.');
      filt(kk) = mfir(plist([param('pzmodel', pzm) param('fs', fs)]));
      
    else
      warning('!!! un-recognised input filter type. Can''t redesign.');
      continue;
    end
    
    % Set the retained properties
    filt(kk).name   = name;
    filt(kk).iunits = iunits;
    filt(kk).ounits = ounits;
    
    % Add history
    filt(kk).addHistory(getInfo('None'), pls, filt_invars(kk), hist);
    
  end
  
  %%% Set output.
  varargout{1} = filt;
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist();
  
  % sample rate
  p = param({'fs', 'Redesign the input filter to work for this sample rate.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

