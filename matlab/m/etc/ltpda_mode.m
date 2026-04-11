% Returns the current operating mode of LTPDA.
% 
% 
function mode = ltpda_mode()
  
  mode = getappdata(0, 'LTPDA_MODE');
  if isempty(mode)
    mode = 0;
  end
  
end
% END