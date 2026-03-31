

function objCl = getClassFromStruct(obj_struct)
  
  objCl = '';
  if isfield(obj_struct, 'class')
    objCl = obj_struct.class;
  elseif isstruct(obj_struct)
    cls = utils.helper.ltpda_non_abstract_classes();
    snames = fieldnames(obj_struct);
    for jj=1:numel(cls)
      cl = cls{jj};
      m = meta.class.fromName(cl);
      p = [m.Properties{:}];
      idxPub = [strcmpi({p.GetAccess}, 'public')] & ~[p.Hidden];
      pubCnames = {p(idxPub).Name}; % public and not hidden properties. (same as properties(cl))
      allCnames = {p.Name}; % 
      if numel(allCnames) == numel(snames) && all(utils.helper.ismember(snames, allCnames))
        objCl = cl;
        return;
      elseif numel(pubCnames) == numel(snames) && all(utils.helper.ismember(snames, pubCnames))
        objCl = cl;
        return;
      end
    end
  end
  
end
