% FROMPROCINFO returns for a given key-name the value of the procinfo-plist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FROMPROCINFO returns for a given key-name the value of the
%              procinfo - parameter list
%
% CALL:        val = fromProcinfo(obj, 'key');
%              val = obj.fromProcinfo('key');
%              val = obj.fromProcinfo(plist('key', 'key_name'));
%
% PARAMETERS:  'key': key-name which should be found in the procinfo-plist
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'fromProcinfo')">Parameters Description</a>
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function val = fromProcinfo(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    val = getInfo(varargin{3});
    return
  end

  % Collect all AOs
  as  = utils.helper.collect_objects(varargin(:), 'ao');
  pl  = utils.helper.collect_objects(varargin(:), 'plist');
  key = utils.helper.collect_objects(varargin(:), 'char');
  
  if isempty(key) && ~isempty(pl) && pl.nparams == 1 && pl.isparam_core('key')
    key = pl.find_core('key');
  end
  
  if ~ischar(key)
    error('### Please specify only one key as a string.');
  end
  
  if numel(as) ~= 1
    error('### This method works only for one input AO.');
  end
  
  val = as.procinfo.find_core(key);
  
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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

function plo = buildplist()
  plo = plist('key', '');
end


