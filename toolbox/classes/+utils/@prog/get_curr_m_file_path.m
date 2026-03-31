function pth = get_curr_m_file_path (m_file_name)
% GET_CURR_M_FILE_PATH returns the path for a mfile.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GET_CURR_M_FILE_PATH returns the path for a mfile.
%
% CALL:        path = get_curr_m_file_path(mfilename)
%              path = get_curr_m_file_path('explore_ao')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pth = '';
eval (sprintf('pth = which(''%s'');',m_file_name))
index = find(pth==filesep, 1, 'last');
pth   = pth(1:index);