%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    ssmFromDescription
%
% DESCRIPTION: Construct a statespace model from a plist description
%
% CALL:        see ssm, this function is private
%
% TODO:        inplement multiple i/o when subassign function is done
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sys = ssmFromDescription(pli)
  
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  
  % get info
  ii = ssm.getInfo('ssm', 'From Description');
  
  % Get default params
  pl = combine(pli, ii.plists);
  if ~isa(pl,'plist') % checking input type
    error(['error because input is not a plist but a ', class(pl)]);
  end
  
  sys = ssm.initObjectWithSize(1,1);
  
  % filling compulsory user defined fields
  userfields = { 'name' 'timestep' 'amats' 'bmats' 'cmats' 'dmats' 'description'};
  
  % other optional fields that may be used defined
  otherfields = { 'params' 'inputs' 'outputs' 'states'};
  dependentFields = {'statenames' 'inputnames' 'outputnames'};
  
  for f = userfields
    if ~isparam(pl, f{1})
      display(['###  ERROR : field in ssm named ''',f{1},''' must be user defined  ###']);
      display('###        list of other compulsory user defined  fields        ###')
      display(char(userfields))
      display('###         list of other optional user defined  fields         ###')
      display(char(otherfields))
      display('###                  list of other shortcuts                    ###')
      display(char(dependentFields))
      error(['see above message and lists ^^ ']);
    end
  end
  
  % add history
  sys.addHistory(ii, pl, {''}, []);
  
  % Set other properties from the plist
  for f = userfields
    sys.(f{1})=find(pl, f{1});
  end
  
  for f = [otherfields dependentFields]
    if isparam(pl, f{1})
      if ~isempty(find(pl, f{1}))
        sys.(f{1})=find(pl, f{1});
      end
    end
  end
  
  sys.validate;
  
end


