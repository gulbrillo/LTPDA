% FROMSTRUCT sets all properties which are defined in the ltpda_uoh class from the structure to the input object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromStruct
%
% DESCRIPTION: Sets all properties which are defined in the ltpda_uoh class
%              from the structure to the input object.
%
% REMARK:      Abstract classes handle only one input object and a
%              structure with the size 1.
%
% CALL:        obj = fromStruct(obj, struct)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = fromStruct(obj, obj_struct)
  
  % Call super-class
  obj = fromStruct@ltpda_uo(obj, obj_struct);
  
  if  isfield(obj_struct, 'historyArray') && ...
      isfield(obj_struct, 'hist')         && ...
      ~isempty(obj_struct.historyArray)   && ...
      ischar(obj_struct.hist)
    
    rootNodeUUID = obj_struct.hist;
    hists = utils.helper.getObjectFromStruct(obj_struct.historyArray);
    
    uuids = expandHistory(hists);
    
    idx = strcmp(rootNodeUUID, uuids);
    obj.hist = hists(idx);
    obj.historyArray = [];
    
  elseif isfield(obj_struct, 'hist')
    % Set 'hist' object
    obj.hist = utils.helper.getObjectFromStruct(obj_struct.hist);
  end
  
%   % Expand 'historyArray'
%   if isfield(obj_struct, 'historyArray') && ~isempty(obj.hist)
%     obj.historyArray = utils.helper.getObjectFromStruct(obj_struct.historyArray);
%     
%     rootNodeUUID = obj.hist;
%     hists = obj.historyArray;
%     
%     uuids = expandHistory(hists);
%     
%     idx = strcmp(rootNodeUUID, uuids);
%     obj.hist = hists(idx);
%     obj.historyArray = [];
%   end
  
  % Set 'procinfo' object
  if isfield(obj_struct, 'procinfo')
    obj.procinfo = utils.helper.getObjectFromStruct(obj_struct.procinfo);
  end
  
  % Set 'timespan' object
  if isfield(obj_struct, 'timespan')
    obj.timespan = utils.helper.getObjectFromStruct(obj_struct.timespan);
  end
  
  % Set 'plotinfo' object
  if isfield(obj_struct, 'plotinfo')
    pi = utils.helper.getObjectFromStruct(obj_struct.plotinfo);
    if isa(pi, 'plist')
      % update to the new plotinfo class
      pi = plotinfo(pi);
    end
    obj.plotinfo = pi;
  end
  
end
