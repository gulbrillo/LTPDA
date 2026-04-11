% CUTSTRING Cuts a string to maximum length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CUTSTRING Cuts a string to maximum length
%
% CALL:   out = utils.prog.cutString(obj, maximum_length)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = cutString(in, max_length)
  
  if max_length < length(in)
    out = in(1:min(max_length, length(in)));
    out = [out ' ...'];
  else
    out = in;
  end
  
end