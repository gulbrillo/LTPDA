% ADDHISTORYWOCHANGINGUUID Add a history-object to the ltpda_uo object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Add a history-object to the ltpda_uoh object.
%
% CALL:        obj = addHistoryWoChangingUUID(obj, minfo, h_pl, var_name, inhists, ...);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = addHistoryWoChangingUUID(varargin)
  
  UUIDs = {varargin{1}.UUID};
  
  if nargout == 0
    addHistory(varargin{:});
    for ii = 1:numel(varargin{1})
      varargin{1}(ii).UUID = UUIDs{ii};
    end
  else
    varargout{:} = addHistory(varargin{:});
    for ii = 1:numel(varargout{1})
      varargout{1}(ii).UUID = UUIDs{ii};
    end
  end
  
end
