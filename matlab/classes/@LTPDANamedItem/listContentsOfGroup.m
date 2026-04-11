% listContentsOfGroup lists the MTelemetry constructors for the
% requested group.
%
% CALL
%         params = MTelemetry.listContentsOfGroup(className, group)
%
%
function params = listContentsOfGroup(className, gname)
  
  m = meta.class.fromName(className);
  methods = m.MethodList;
  methods = methods([methods.Static]);
  mnames = {methods.Name};
  
  params = mnames(strncmp(gname, mnames, length(gname)))';
  
end % listContentsOfGroup
% END