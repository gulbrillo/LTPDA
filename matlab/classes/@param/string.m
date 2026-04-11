% STRING writes a command string that can be used to recreate the input param object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING writes a command string that can be used to recreate the
%              input param object.
%
% CALL:        cmd = string(param_obj)
%
% INPUT:       param_obj - parameter object
%
% OUTPUT:      cmd       - command string to create the input object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)
  
  objs = [varargin{:}];
  
  cmd = '';
  
  for ii = 1:numel(objs)
    
    key = objs(ii).key;
    val = objs(ii).getVal;
    
    if ischar(val)
      val_str = ['''' strrep(val, '''', '''''') ''''];
    elseif isnumeric(val)
      val_str = mat2str(val);
    elseif isa(val, 'ltpda_obj')
      val_str = string(val);
    elseif iscell(val)
      val_str = utils.prog.mcell2str(val);
    else
      error('### Unknown object [%s]', class(val));
    end
    
    if iscell(key)
      keystr = key{1};
    else
      keystr = key;
    end
    cmd = [cmd 'param(''' key ''', ' val_str ') '];
  end
  
  %%% Wrap the command only in bracket if the there are more than one object
  if numel(objs) > 1
    cmd = ['[' cmd(1:end-1) ']'];
  end
  
  %%% Prepare output
  varargout{1} = cmd;
end

