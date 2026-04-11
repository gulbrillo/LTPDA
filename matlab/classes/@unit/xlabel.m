% XLABEL place a xlabel on the given axes taking into account the units and
% the desired label.
%
% The units are stored in the UserData of the axes objects. Any existing
% units are checked and if they don't match these current units, we use the
% placeholder 'mixed'.
%
% The handles to the text objects are returned.
%
% CALL:
%         texthandle = xlabel(unit, axesHandle, label)
%

function th = xlabel(u, ah, label)
  
  th = [];
  for kk=1:numel(ah)
    udata = get(ah(kk), 'UserData');
    if isa(udata, 'plist')
      existingUnits = udata.find('xunits');
      if isempty(existingUnits)
        existingUnits = u;
      end
    else
      udata = plist();
      existingUnits = u;
    end
    
    if isequal(u, existingUnits)
      ustr = char(u);
      storeUnit = u;
    else
      ustr = '[mixed]';
      storeUnit = 'mixed';
    end
    
    th = [th xlabel(ah(kk), utils.plottools.fixAxisLabel(sprintf('%s %s', label, ustr)))];
    set(ah(kk), 'UserData', udata.pset('xunits', storeUnit));
  end
  
end
% END
