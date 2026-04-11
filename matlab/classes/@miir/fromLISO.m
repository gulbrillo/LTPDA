% FROMLISO Construct a miir filter from a LISO file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromLISO
%
% DESCRIPTION: Construct a miir filter from a LISO file
%
% CALL:        f = fromLISO(f, pli)
%
% PARAMETER:   f:   Empty miir-object
%              pli: input plist (must contain the filename)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f = fromLISO(f, pli)
  
  ii = f.getInfo(class(f), 'From LISO File');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  filename   = find_core(pl, 'filename');
  filt       = miir.filload(filename);
  
  f.name     = filt.name;
  f.fs       = filt.fs;
  f.a        = filt.gain*filt.a;
  f.b        = filt.b;
  f.histin   = filt.histin;
  f.histout  = filt.histout;
  f.infile   = filename;
  
  if isempty(pl.find_core('name'))
    pl.pset('name', filt.name);
  end
  
  f.addHistory(ii, pl, [], []);
  
  % Set object properties
  f.setObjectProperties(pl);
  
end % pzm = pzmFromLISO(filename, version, algoname)

