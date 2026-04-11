% FROMAOS construct a pest object from different values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromAOs
%
% DESCRIPTION: Construct a pest object from different AOs.
%
% CALL:        pe = fromAOs(pe, pli)
%
% PARAMETER:   pe  - empty pest object
%              pli - input plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = fromAOs(obj, pli)
  
  % get pzmodel info
  ii = pest.getInfo('pest', 'From Aos');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % get AOs
  aos = pl.find('aos');
  
  % Check that the AOs have a single cdata value
  idx = arrayfun(@(x) isa(x.data, 'cdata'), aos);
  assert(all(idx), 'Please provide only AOs with cdata objects. The AO(s) [%s] doesn''t have a cdata object', strtrim(sprintf('%d ', find(~idx))))
  
  % Check that the AOs have only one value
  idx = arrayfun(@(obj) numel(obj.y)==1, aos);
  assert(all(idx), 'Please provide only AOs with a single value. The AO(s) [%s] doesn''t have a single value', strtrim(sprintf('%d ', find(~idx))))
  
  % Check that the AO names can be used as variable names
  names = {aos.name};
  idx = cellfun(@(x) isvarname(x), names);
  assert(all(idx), 'Please provide only AOs with valid names for the parameters. The AO(s) [%s] doesn''t have valid names', strtrim(sprintf('%d ', find(~idx))))
  
  % Get dy from the AOs. Not each AO have a 'dy'
  dy = zeros(1, numel(aos));
  idx = arrayfun(@(obj) ~isempty(obj.dy), aos);
  dy(idx) = [aos.dy];
  
  % Set the values
  obj.y      = [aos.y];
  obj.names  = names;
  obj.dy     = dy;
  obj.yunits = [aos.yunits];
  
  % Add history
  obj.addHistory(ii, pl, [], []);
  
  % Set object properties
  obj.setObjectProperties(pl);
  
end
