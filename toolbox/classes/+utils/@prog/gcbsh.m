function varargout = gcbsh()

% GCBSH gets the handles for the currently selected blocks.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% GCBSH gets the handles for the currently selected blocks.
% 
% Usage: >> gcbsh
%        >> h = gcbsh
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = [];

blks = find_system(gcs, 'SearchDepth',1, 'LookUnderMasks', 'all', 'Type', 'block');
hs   = get_param(blks, 'Handle');

% get selected blocks
for j=1:length(hs)
  if get_param(gcs, 'Handle') ~= hs{j}
    if strcmp(get(hs{j}, 'Selected'), 'on')
      h = [h hs{j}];
    end
  end
end

if nargout == 0
  disp(h.')
elseif nargout == 1
  varargout{1} = h.';
else
  error('### Too many output arguments')
end