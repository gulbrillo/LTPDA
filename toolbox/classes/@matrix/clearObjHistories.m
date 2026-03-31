% CLEAROBJHISTORIES Clear the history of the inside objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CLEAROBJHISTORIES Clear the history of the inside objects..
%
% CALL:        ao_out = clearObjHistories(matrix-object);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = clearObjHistories(varargin)
  
  if nargin ~= 1
    error('### This method works only with one input.');
  end
  
  mObjs = varargin{1};
  
  for mm=1:numel(mObjs)
    for ii = 1:numel(mObjs(mm).objs)
      if isa(mObjs(mm).objs(ii), 'ltpda_uoh')
        clearHistory(mObjs(mm).objs(ii));
      end
    end
  end
  
end
