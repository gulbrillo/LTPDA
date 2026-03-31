% Construct a collection object from ltpda_uoh objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromInput
%
% DESCRIPTION: Construct a collection object from ltpda_uoh objects.
%
% CALL:        collection = collection.fromInput(inobjs)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = fromInput(obj, varargin)
  
  import utils.const.*
  utils.helper.msg(msg.OPROC1, 'Construct from inputs');
  
  % Identify the objects which should go into the collection.
  [inobjs, plConfig] = collection.identifyInsideObjs(varargin{:});
  
  % get the names now from the config plist
  names = plConfig.find_core('names');
  
  % apply defaults
  dpl = collection.getDefaultPlist('From Input');
  plConfig = applyDefaults(dpl, plConfig);
  
  % now combine any config plist with the user's input plist, ignoring the
  % 'objs' key which is handled independently to ensure that ltpda_uoh
  % objects go in the history (as input histories) and object-plists go in
  % the history plist under the 'objs' key.
%   if isparam_core(plConfig, 'objs')
%     plConfig.remove('objs');
%   end
      
  % Set the inside objects
  obj.objs = inobjs;
  obj.names = names;
  
%   inhists  = [];
%   inplists = {};
%   if ~isempty(inobjs)
%     % Loop over the 'inobjs' because it is possible that a plist which
%     % doesn't have a history is in 'inobjs'
%     for ll = 1:numel(inobjs)
%       if isa(inobjs{ll}, 'ltpda_uoh')
%         inhists = [inhists inobjs{ll}.hist];
%       else
%         inplists = [inplists inobjs(ll)];
%       end
%     end
%   end
  
  % Add the input plists again as a value to the history-plist because the
  % plists doesn't have history-steps which we can add to the collection
  % object.
%   if ~isempty(inplists)
    plHist = plConfig.pset('objs', inobjs);
%   else
%     plHist = plConfig;
%   end
  
  obj.addHistory(collection.getInfo('collection', 'None'), plHist, [], []);
  
  % Set object properties
  obj.setObjectProperties(plConfig, {'objs', 'names'});
end
