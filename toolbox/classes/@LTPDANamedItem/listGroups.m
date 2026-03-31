% LISTGROUPS lists the different telemetry groups.
%
% CALL
%              MTelemetry.listGroups(className)
%
function groups = listGroups(className)
  
  m = meta.class.fromName(className);
  methods = m.MethodList;
  methods = methods([methods.Static]);
  mnames = {methods.Name};
  
  ggs = regexp(mnames, '(^[A-Z][a-zA-Z]*)_', 'tokens');
  ggs = ggs(~cellfun('isempty', ggs));
  ggs = [ggs{:}];
  ggs = [ggs{:}];
  groups = unique(ggs);
  
  % remove known none-groups
  groups(strcmp(groups, 'CACHE')) = [];
  
end % End list groups
% END