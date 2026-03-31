% STRING writes a command string that can be used to recreate the input minfo object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: STRING writes a command string that can be used to recreate
%              the input minfo object.
%
% CALL:        cmd = string(minfo)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = string(varargin)
  
  mi = utils.helper.collect_objects(varargin(:), 'minfo');
  
  cmd = '';
  for j=1:numel(mi)

    plstr = string(mi(j).plists);
    if isempty(plstr)
      plstr = '[]';
    end
    
    mistr = 'minfo(';
    mistr = [mistr, utils.helper.val2str(mi(j).mname), ', '];
    mistr = [mistr, utils.helper.val2str(mi(j).mclass), ', '];
    mistr = [mistr, utils.helper.val2str(mi(j).mpackage), ', '];
    mistr = [mistr, utils.helper.val2str(mi(j).mcategory), ', '];
    mistr = [mistr, utils.helper.val2str(mi(j).mversion), ', '];
    mistr = [mistr, utils.prog.cell2str(mi(j).sets), ', '];
    mistr = [mistr, plstr, ', '];
    mistr = [mistr, num2str(mi(j).argsmin), ', '];
    mistr = [mistr, num2str(mi(j).argsmax), ', '];
    mistr = [mistr, num2str(mi(j).outmin), ', '];
    mistr = [mistr, num2str(mi(j).outmax), ', '];
    mistr = [mistr, mat2str(mi(j).modifier), ') '];
    
    cmd = [cmd mistr];
    
  end
  
  %%% Wrap the command only with brackets if the there are more than one object
  if numel(mi) > 1
    cmd = ['[' cmd(1:end-1) ']'];
  end
  
  % set output
  varargout{1} = cmd;
end

