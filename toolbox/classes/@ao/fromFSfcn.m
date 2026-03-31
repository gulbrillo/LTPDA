% FROMFSFCN Construct an ao from a fs-function string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromFSfcn
%
% DESCRIPTION: Construct an ao from a fs-function string
%
% CALL:        a = fromFSfcn(a, pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromFSfcn(a, pli)
  
  import utils.const.*
  
  % get AO info
  ii = ao.getInfo('ao', 'From Frequency-series Function');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  pl.getSetRandState();
  f  = find_core(pl, 'f');
  
  if isempty(f)
    utils.helper.msg(msg.PROC2, 'generating f vector');
    f1 = find_core(pl, 'f1');
    f2 = find_core(pl, 'f2');
    nf = find_core(pl, 'nf');
    scale = find_core(pl, 'scale');
    switch lower(scale)
      case 'log'
        f = logspace(log10(f1), log10(f2), nf);
      case 'lin'
        f = linspace(f1, f2, nf);
      otherwise
        error('### Unknown frequency scale specified');
    end
  elseif ischar(f)
    f = eval(f);
  elseif isa(f, 'ao')
    f = f.data.getX;
  end
  
  % Get the function
  fcn = find_core(pl, 'fsfcn');
  
  % make y data
  y = eval([fcn ';']);
  
  fs = fsdata(f,y);
  
  % Make an analysis object
  a.data  = fs;
  
  % Add history
  a.addHistory(ii, pl, [], []);
  
  % Set errors from plist
  a.data.setErrorsFromPlist(pl);
  
  % set x and y units
  a.data.setXunits(pl.find_core('xunits'));
  a.data.setYunits(pl.find_core('yunits'));
  
  % Set object properties from the plist
  a.setObjectProperties(pl, {'xunits', 'yunits'});
  
end

